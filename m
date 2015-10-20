Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id AC01582F64
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 11:54:17 -0400 (EDT)
Received: by igbni9 with SMTP id ni9so74836011igb.1
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 08:54:17 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id j204si3624843ioe.84.2015.10.20.08.54.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Oct 2015 08:54:16 -0700 (PDT)
Message-ID: <1445356379.4486.56.camel@infradead.org>
Subject: [RFC PATCH] iommu/vt-d: Add IOTLB flush support for kernel addresses
From: David Woodhouse <dwmw2@infradead.org>
Date: Tue, 20 Oct 2015 16:52:59 +0100
Content-Type: multipart/signed; micalg="sha-1"; protocol="application/x-pkcs7-signature";
	boundary="=-1F1Ran7M4eE1plFnGs7E"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: iommu@lists.linux-foundation.org, Sudeep Dutt <sudeep.dutt@intel.com>


--=-1F1Ran7M4eE1plFnGs7E
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On top of the tree at git.infradead.org/users/dwmw2/linux-svm.git
(http:// or git://).

For userspace addresses, we use the MMU notifiers and flush the IOTLB
as appropriate.

However, we need to do it for kernel addresses too =E2=80=94 which basicall=
y
means adding a hook to tlb_flush_kernel_range(). Does this look
reasonable? I was trying to avoid it and insist on supporting addresses
within the kernel's static mapping only. But it doesn't look like
that's a reasonable thing to require.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 arch/x86/mm/tlb.c           |    2 ++
 drivers/iommu/intel-svm.c   |   37 ++++++++++++++++++++++++++++++++++---
 include/linux/intel-iommu.h |    6 +++++-
 include/linux/intel-svm.h   |   13 +++++--------
 4 files changed, 46 insertions(+), 12 deletions(-)

diff --git a/include/linux/intel-svm.h b/include/linux/intel-svm.h
index 0a48ccf..61d9533 100644
--- a/include/linux/intel-svm.h
+++ b/include/linux/intel-svm.h
@@ -44,14 +44,11 @@ struct svm_dev_ops {
=20
 /*
  * The SVM_FLAG_SUPERVISOR_MODE flag requests a PASID which can be used on=
ly
- * for access to kernel addresses. No IOTLB flushes are automatically done
- * for kernel mappings; it is valid only for access to the kernel's static
- * 1:1 mapping of physical memory =E2=80=94 not to vmalloc or even module =
mappings.
- * A future API addition may permit the use of such ranges, by means of an
- * explicit IOTLB flush call (akin to the DMA API's unmap method).
- *
- * It is unlikely that we will ever hook into flush_tlb_kernel_range() to
- * do such IOTLB flushes automatically.
+ * for access to kernel addresses. IOTLB flushes are performed as required
+ * by means of a hook from flush_tlb_kernel_range(). This flag is mutually
+ * exclusive with the SVM_FLAG_PRIVATE_PASID flag =E2=80=94 there can be o=
nly one
+ * PASID used for kernel mode, to keep the performance implications of the
+ * IOTLB flush hook relatively sane.
  */
 #define SVM_FLAG_SUPERVISOR_MODE	(1<<1)
 diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 8ddb5d0..40ebe83 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -6,6 +6,7 @@
 #include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/cpu.h>
+#include <linux/intel-iommu.h>
=20
 #include <asm/tlbflush.h>
 #include <asm/mmu_context.h>
@@ -266,6 +267,7 @@ static void do_kernel_range_flush(void *info)
=20
 void flush_tlb_kernel_range(unsigned long start, unsigned long end)
 {
+	intel_iommu_flush_kernel_pasid(start, end);
=20
 	/* Balance as user space task's flush, a bit conservative */
 	if (end =3D=3D TLB_FLUSH_ALL ||
diff --git a/drivers/iommu/intel-svm.c b/drivers/iommu/intel-svm.c
index a584df0..f8ca3c1 100644
--- a/drivers/iommu/intel-svm.c
+++ b/drivers/iommu/intel-svm.c
@@ -23,6 +23,7 @@
 #include <linux/pci-ats.h>
 #include <linux/dmar.h>
 #include <linux/interrupt.h>
+#include <asm/tlbflush.h>
=20
 static irqreturn_t prq_event_thread(int irq, void *d);
=20
@@ -264,6 +265,26 @@ static const struct mmu_notifier_ops intel_mmuops =3D =
{
 	.invalidate_range =3D intel_invalidate_range,
 };
=20
+void intel_iommu_flush_kernel_pasid(unsigned long start, unsigned long end=
)
+{
+	struct dmar_drhd_unit *drhd;
+	struct intel_iommu *iommu;
+	unsigned long pages;
+
+	if (end =3D=3D TLB_FLUSH_ALL)
+		pages =3D end;
+	else
+		pages =3D (end - start) >> VTD_PAGE_SHIFT;
+
+	rcu_read_lock();
+	for_each_active_iommu(iommu, drhd) {
+		struct intel_svm *svm =3D rcu_dereference(iommu->kernel_svm);
+		if (svm)
+			intel_flush_svm_range(svm, start, pages, 0, 1);
+	}
+	rcu_read_unlock();
+}
+
 static DEFINE_MUTEX(pasid_mutex);
=20
 int intel_svm_bind_mm(struct device *dev, int *pasid, int flags, struct sv=
m_dev_ops *ops)
@@ -286,6 +307,8 @@ int intel_svm_bind_mm(struct device *dev, int *pasid, i=
nt flags, struct svm_dev_
 		pasid_max =3D 1 << 20;
=20
 	if ((flags & SVM_FLAG_SUPERVISOR_MODE)) {
+		if (flags & SVM_FLAG_PRIVATE_PASID)
+			return -EINVAL;
 		if (!ecap_srs(iommu->ecap))
 			return -EINVAL;
 	} else if (pasid) {
@@ -294,7 +317,9 @@ int intel_svm_bind_mm(struct device *dev, int *pasid, i=
nt flags, struct svm_dev_
 	}
=20
 	mutex_lock(&pasid_mutex);
-	if (pasid && !(flags & SVM_FLAG_PRIVATE_PASID)) {
+	if (SVM_FLAG_SUPERVISOR_MODE)
+		svm =3D iommu->kernel_svm;
+	else if (pasid && !(flags & SVM_FLAG_PRIVATE_PASID)) {
 		int i;
=20
 		idr_for_each_entry(&iommu->pasid_idr, svm, i) {
@@ -378,8 +403,10 @@ int intel_svm_bind_mm(struct device *dev, int *pasid, =
int flags, struct svm_dev_
 			}
 			iommu->pasid_table[svm->pasid].val =3D (u64)__pa(mm->pgd) | 1;
 			mm =3D NULL;
-		} else
+		} else {
 			iommu->pasid_table[svm->pasid].val =3D (u64)__pa(init_mm.pgd) | 1 | (1U=
LL << 11);
+			rcu_assign_pointer(iommu->kernel_svm, svm);
+		}
 		wmb();
 	}
 	list_add_rcu(&sdev->list, &svm->devs);
@@ -432,8 +459,12 @@ int intel_svm_unbind_mm(struct device *dev, int pasid)
 					mmu_notifier_unregister(&svm->notifier, svm->mm);
=20
 					idr_remove(&svm->iommu->pasid_idr, svm->pasid);
-					if (svm->mm)
+					if (svm->mm) {
 						mmput(svm->mm);
+					} else {
+						rcu_assign_pointer(iommu->kernel_svm, NULL);
+						synchronize_rcu();
+					}
 					/* We mandate that no page faults may be outstanding
 					 * for the PASID when intel_svm_unbind_mm() is called.
 					 * If that is not obeyed, subtle errors will happen.
diff --git a/include/linux/intel-iommu.h b/include/linux/intel-iommu.h
index 821273c..169bc84 100644
--- a/include/linux/intel-iommu.h
+++ b/include/linux/intel-iommu.h
@@ -391,6 +391,7 @@ enum {
 struct pasid_entry;
 struct pasid_state_entry;
 struct page_req_dsc;
+struct intel_svm;
=20
 struct intel_iommu {
 	void __iomem	*reg; /* Pointer to hardware regs, virtual addr */
@@ -426,6 +427,7 @@ struct intel_iommu {
 	struct page_req_dsc *prq;
 	unsigned char prq_name[16];    /* Name for PRQ interrupt */
 	struct idr pasid_idr;
+	struct intel_svm __rcu *kernel_svm;
 #endif
 	struct q_inval  *qi;            /* Queued invalidation info */
 	u32 *iommu_state; /* Store iommu states between suspend and resume.*/
@@ -496,8 +498,10 @@ struct intel_svm {
=20
 extern int intel_iommu_enable_pasid(struct intel_iommu *iommu, struct inte=
l_svm_dev *sdev);
 extern struct intel_iommu *intel_svm_device_to_iommu(struct device *dev);
+extern void intel_iommu_flush_kernel_pasid(unsigned long start, unsigned l=
ong end);
+#else
+#define intel_iommu_flush_kernel_pasid(start, end) do { ; } while(0)
 #endif
-
 extern const struct attribute_group *intel_iommu_groups[];
=20
 #endif

--=20
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation


--=-1F1Ran7M4eE1plFnGs7E
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIISjjCCBicw
ggUPoAMCAQICAw3vNzANBgkqhkiG9w0BAQUFADCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0
YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcx
ODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENB
MB4XDTE1MDUwNTA5NDM0MVoXDTE2MDUwNTA5NTMzNlowQjEcMBoGA1UEAwwTZHdtdzJAaW5mcmFk
ZWFkLm9yZzEiMCAGCSqGSIb3DQEJARYTZHdtdzJAaW5mcmFkZWFkLm9yZzCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAMkbm9kPbx1j/X4RVyf/pPKSYwelcco69TvnQQbKM8m8xkWjXJI1
jpJ1jMaGUZGFToINMSZi7lZawUozudWbXSKy1SikENSTJHffsdRAIlsp+hR8vWvjsKUry6sEdqPG
doa5RY7+N4WRusWZDYW/RRWE6i9EL9qV86CVPYqw22UBOUw4/j/HVGCV6TSB8yE5iEwhk/hUuzRr
FZm1MJMR7mCS7BCR8Lr5jFY61lWpBiXNXIxLZCvDc26KR5L5tYX43iUVO3fzES1GRVoYnxxk2tmz
fcsZG5vK+Trc9L8OZJfkYrEHH3+Iw41MQ0w/djVtYr1+HYldx0QmYXAtnhIj+UMCAwEAAaOCAtkw
ggLVMAkGA1UdEwQCMAAwCwYDVR0PBAQDAgSwMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcD
BDAdBgNVHQ4EFgQUszC96C3w5/2+d+atSr0IpT26YI4wHwYDVR0jBBgwFoAUU3Ltkpzg2ssBXHx+
ljVO8tS4UYIwHgYDVR0RBBcwFYETZHdtdzJAaW5mcmFkZWFkLm9yZzCCAUwGA1UdIASCAUMwggE/
MIIBOwYLKwYBBAGBtTcBAgMwggEqMC4GCCsGAQUFBwIBFiJodHRwOi8vd3d3LnN0YXJ0c3NsLmNv
bS9wb2xpY3kucGRmMIH3BggrBgEFBQcCAjCB6jAnFiBTdGFydENvbSBDZXJ0aWZpY2F0aW9uIEF1
dGhvcml0eTADAgEBGoG+VGhpcyBjZXJ0aWZpY2F0ZSB3YXMgaXNzdWVkIGFjY29yZGluZyB0byB0
aGUgQ2xhc3MgMSBWYWxpZGF0aW9uIHJlcXVpcmVtZW50cyBvZiB0aGUgU3RhcnRDb20gQ0EgcG9s
aWN5LCByZWxpYW5jZSBvbmx5IGZvciB0aGUgaW50ZW5kZWQgcHVycG9zZSBpbiBjb21wbGlhbmNl
IG9mIHRoZSByZWx5aW5nIHBhcnR5IG9ibGlnYXRpb25zLjA2BgNVHR8ELzAtMCugKaAnhiVodHRw
Oi8vY3JsLnN0YXJ0c3NsLmNvbS9jcnR1MS1jcmwuY3JsMIGOBggrBgEFBQcBAQSBgTB/MDkGCCsG
AQUFBzABhi1odHRwOi8vb2NzcC5zdGFydHNzbC5jb20vc3ViL2NsYXNzMS9jbGllbnQvY2EwQgYI
KwYBBQUHMAKGNmh0dHA6Ly9haWEuc3RhcnRzc2wuY29tL2NlcnRzL3N1Yi5jbGFzczEuY2xpZW50
LmNhLmNydDAjBgNVHRIEHDAahhhodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS8wDQYJKoZIhvcNAQEF
BQADggEBAHMQmxHHodpS85X8HRyxhvfkys7r+taCNOaNU9cxQu/cZ/6k5nS2qGNMzZ6jb7ueY/V7
7p+4DW/9ZWODDTf4Fz00mh5SSVc20Bz7t+hhxwHd62PZgENh5i76Qq2tw48U8AsYo5damHby1epf
neZafLpUkLLO7AGBJIiRVTevdvyXQ0qnixOmKMWyvrhSNGuVIKVdeqLP+102Dwf+dpFyw+j1hz28
jEEKpHa+NR1b2kXuSPi/rMGhexwlJOh4tK8KQ6Ryr0rIN//NSbOgbyYZrzc/ZUWX9V5OA84ChFb2
vkFl0OcYrttp/rhDBLITwffPxSZeoBh9H7zYzkbCXKL3BUIwggYnMIIFD6ADAgECAgMN7zcwDQYJ
KoZIhvcNAQEFBQAwgYwxCzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSswKQYD
VQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFydENv
bSBDbGFzcyAxIFByaW1hcnkgSW50ZXJtZWRpYXRlIENsaWVudCBDQTAeFw0xNTA1MDUwOTQzNDFa
Fw0xNjA1MDUwOTUzMzZaMEIxHDAaBgNVBAMME2R3bXcyQGluZnJhZGVhZC5vcmcxIjAgBgkqhkiG
9w0BCQEWE2R3bXcyQGluZnJhZGVhZC5vcmcwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
AQDJG5vZD28dY/1+EVcn/6TykmMHpXHKOvU750EGyjPJvMZFo1ySNY6SdYzGhlGRhU6CDTEmYu5W
WsFKM7nVm10istUopBDUkyR337HUQCJbKfoUfL1r47ClK8urBHajxnaGuUWO/jeFkbrFmQ2Fv0UV
hOovRC/alfOglT2KsNtlATlMOP4/x1Rglek0gfMhOYhMIZP4VLs0axWZtTCTEe5gkuwQkfC6+YxW
OtZVqQYlzVyMS2Qrw3NuikeS+bWF+N4lFTt38xEtRkVaGJ8cZNrZs33LGRubyvk63PS/DmSX5GKx
Bx9/iMONTENMP3Y1bWK9fh2JXcdEJmFwLZ4SI/lDAgMBAAGjggLZMIIC1TAJBgNVHRMEAjAAMAsG
A1UdDwQEAwIEsDAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwQwHQYDVR0OBBYEFLMwvegt
8Of9vnfmrUq9CKU9umCOMB8GA1UdIwQYMBaAFFNy7ZKc4NrLAVx8fpY1TvLUuFGCMB4GA1UdEQQX
MBWBE2R3bXcyQGluZnJhZGVhZC5vcmcwggFMBgNVHSAEggFDMIIBPzCCATsGCysGAQQBgbU3AQID
MIIBKjAuBggrBgEFBQcCARYiaHR0cDovL3d3dy5zdGFydHNzbC5jb20vcG9saWN5LnBkZjCB9wYI
KwYBBQUHAgIwgeowJxYgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwAwIBARqBvlRo
aXMgY2VydGlmaWNhdGUgd2FzIGlzc3VlZCBhY2NvcmRpbmcgdG8gdGhlIENsYXNzIDEgVmFsaWRh
dGlvbiByZXF1aXJlbWVudHMgb2YgdGhlIFN0YXJ0Q29tIENBIHBvbGljeSwgcmVsaWFuY2Ugb25s
eSBmb3IgdGhlIGludGVuZGVkIHB1cnBvc2UgaW4gY29tcGxpYW5jZSBvZiB0aGUgcmVseWluZyBw
YXJ0eSBvYmxpZ2F0aW9ucy4wNgYDVR0fBC8wLTAroCmgJ4YlaHR0cDovL2NybC5zdGFydHNzbC5j
b20vY3J0dTEtY3JsLmNybDCBjgYIKwYBBQUHAQEEgYEwfzA5BggrBgEFBQcwAYYtaHR0cDovL29j
c3Auc3RhcnRzc2wuY29tL3N1Yi9jbGFzczEvY2xpZW50L2NhMEIGCCsGAQUFBzAChjZodHRwOi8v
YWlhLnN0YXJ0c3NsLmNvbS9jZXJ0cy9zdWIuY2xhc3MxLmNsaWVudC5jYS5jcnQwIwYDVR0SBBww
GoYYaHR0cDovL3d3dy5zdGFydHNzbC5jb20vMA0GCSqGSIb3DQEBBQUAA4IBAQBzEJsRx6HaUvOV
/B0csYb35MrO6/rWgjTmjVPXMULv3Gf+pOZ0tqhjTM2eo2+7nmP1e+6fuA1v/WVjgw03+Bc9NJoe
UklXNtAc+7foYccB3etj2YBDYeYu+kKtrcOPFPALGKOXWph28tXqX53mWny6VJCyzuwBgSSIkVU3
r3b8l0NKp4sTpijFsr64UjRrlSClXXqiz/tdNg8H/naRcsPo9Yc9vIxBCqR2vjUdW9pF7kj4v6zB
oXscJSToeLSvCkOkcq9KyDf/zUmzoG8mGa83P2VFl/VeTgPOAoRW9r5BZdDnGK7baf64QwSyE8H3
z8UmXqAYfR+82M5Gwlyi9wVCMIIGNDCCBBygAwIBAgIBHjANBgkqhkiG9w0BAQUFADB9MQswCQYD
VQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwg
Q2VydGlmaWNhdGUgU2lnbmluZzEpMCcGA1UEAxMgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRo
b3JpdHkwHhcNMDcxMDI0MjEwMTU1WhcNMTcxMDI0MjEwMTU1WjCBjDELMAkGA1UEBhMCSUwxFjAU
BgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRl
IFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUg
Q2xpZW50IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxwmDzM4t2BqxKaQuE6uW
vooyg4ymiEGWVUet1G8SD+rqvyNH4QrvnEIaFHxOhESip7vMz39ScLpNLbL1QpOlPW/tFIzNHS3q
d2XRNYG5Sv9RcGE+T4qbLtsjjJbi6sL7Ls/f/X9ftTyhxvxWkf8KW37iKrueKsxw2HqolH7GM6FX
5UfNAwAu4ZifkpmZzU1slBhyWwaQPEPPZRsWoTb7q8hmgv6Nv3Hg9rmA1/VPBIOQ6SKRkHXG0Hhm
q1dOFoAFI411+a/9nWm5rcVjGcIWZ2v/43Yksq60jExipA4l5uv9/+Hm33mbgmCszdj/Dthf13tg
Av2O83hLJ0exTqfrlwIDAQABo4IBrTCCAakwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMC
AQYwHQYDVR0OBBYEFFNy7ZKc4NrLAVx8fpY1TvLUuFGCMB8GA1UdIwQYMBaAFE4L7xqkQFulF2mH
MMo0aEPQQa7yMGYGCCsGAQUFBwEBBFowWDAnBggrBgEFBQcwAYYbaHR0cDovL29jc3Auc3RhcnRz
c2wuY29tL2NhMC0GCCsGAQUFBzAChiFodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9zZnNjYS5jcnQw
WwYDVR0fBFQwUjAnoCWgI4YhaHR0cDovL3d3dy5zdGFydHNzbC5jb20vc2ZzY2EuY3JsMCegJaAj
hiFodHRwOi8vY3JsLnN0YXJ0c3NsLmNvbS9zZnNjYS5jcmwwgYAGA1UdIAR5MHcwdQYLKwYBBAGB
tTcBAgEwZjAuBggrBgEFBQcCARYiaHR0cDovL3d3dy5zdGFydHNzbC5jb20vcG9saWN5LnBkZjA0
BggrBgEFBQcCARYoaHR0cDovL3d3dy5zdGFydHNzbC5jb20vaW50ZXJtZWRpYXRlLnBkZjANBgkq
hkiG9w0BAQUFAAOCAgEACoMIfXirLAZcuGOMXq4cuSN3TaFx2H2GvD5VSy/6rV55BYHbWNaPeQn3
oBSU8KgQZn/Kck1JxbLpAxVCNtsxeW1R87ifhsYZ0qjdrA9anrW2MAWCtosmAOT4OxK9QPoSjCMx
M3HbkZCDJgnlE8jMopH21BbyAYr7b5EfGRQJNtgWcvqSXwKHnTutR08+Kkn0KAkXCzeQNLeA5LlY
UzFyM7kPAp8pIRMQ+seHunmyG642S2+y/qHEdMuGIwpfz3eDF1PdctL04qYK/zu+Qg1Bw0RwgigV
Zs/0c5HP2/e9DBHh7eSwtzYlk4AUr6yxLlcwSjOfOmKEQ/Q8tzh0IFiNu9IPuTGAPBn4CPxD0+Ru
8T2wg8/s43R/PT3kd1OEqOJUl7q+h+r6fpvU0Fzxd2tC8Ga6fDEPme+1Nbi+03pVjuZQKbGwKJ66
gEn06WqaxVZC+J8hh/jR0k9mST1iAZPNYulcNJ8tKmVtjYsv0L1TSm2+NwON58tO+pIVzu3DWwSE
XSf+qkDavQam+QtEOZxLBXI++aMUEapSn+k3Lxm48ZCYfAWLb/Xj7F5JQMbZvCexglAbYR0kIHqW
5DnsYSdMD/IplJMojx0NBrxJ3fN9dvX2Y6BIXRsF1du4qESm4/3CKuyUV7p9DW3mPlHTGLvYxnyK
Qy7VFBkoLINszBrOUeIxggNvMIIDawIBATCBlDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0
YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcx
ODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENB
AgMN7zcwCQYFKw4DAhoFAKCCAa8wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0B
CQUxDxcNMTUxMDIwMTU1MjU5WjAjBgkqhkiG9w0BCQQxFgQUHQue2Hhr8Vw6qR5ZMo2HyzGkiIIw
gaUGCSsGAQQBgjcQBDGBlzCBlDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0
ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMT
L1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBAgMN7zcwgacG
CyqGSIb3DQEJEAILMYGXoIGUMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRk
LjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMv
U3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0ECAw3vNzANBgkq
hkiG9w0BAQEFAASCAQB4Wr+X/xc/8E17HBoddjrUf2BknXTd7znxtjy1a8pviGH2jZCwIEP4K16n
Fwl2iSAgkay8MDHDwilGb5lScdzeHgnQ5tJbPQ0QW/1CBjumlvDncOrM+8w2al7l1MoUQZ98cgNt
qtckn++3TxALdaDGmCJ+wWtrMmoEAYmbD8XzcvWxqxr3gHQ3WScrrsOouvYlzMvO4W5B0SNhFOJZ
Dz9yzjQCJJ78w0n9LGtwqtSWLNWVkydhcEvV/SK9dP7LvnOPgnSc4niIDQB0NX4R2rCS08IAzo6/
9E3dudsQ0C8oRhxb1U0rgnDq00QEDyYfKIFG78Vr7DNZiPd53RMDjHhRAAAAAAAA


--=-1F1Ran7M4eE1plFnGs7E--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
