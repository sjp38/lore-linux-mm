Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A9E4A828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 16:35:09 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id e65so87739853pfe.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 13:35:09 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id c76si4381534pfj.134.2016.01.13.13.35.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 13:35:08 -0800 (PST)
Message-ID: <1452720905.88154.75.camel@infradead.org>
Subject: [PATCH] iommu/vt-d: Fix mm refcounting to hold mm_count not mm_users
From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 13 Jan 2016 21:35:05 +0000
Content-Type: multipart/signed; micalg="sha-1"; protocol="application/x-pkcs7-signature";
	boundary="=-gQSoAmSpHXo1uQkLFWWl"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: iommu@lists.linux-foundation.org, linux-mm@kvack.org
Cc: "Tang, CQ" <cq.tang@intel.com>


--=-gQSoAmSpHXo1uQkLFWWl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Holding mm_users works OK for graphics, which was the first user of SVM
with VT-d. However, it works less well for other devices, where we actually
do a mmap() from the file descriptor to which the SVM PASID state is tied.

In this case on process exit we end up with a recursive reference count:
=C2=A0- The MM remains alive until the file is closed and the driver's rele=
ase()
=C2=A0=C2=A0=C2=A0call ends up unbinding the PASID.
=C2=A0- The VMA corresponding to the mmap() remains intact until the MM is
=C2=A0=C2=A0=C2=A0destroyed.
=C2=A0- Thus the file isn't closed, even when exit_files() runs, because th=
e
=C2=A0=C2=A0=C2=A0VMA is still holding a reference to it. And the MM remain=
s alive=E2=80=A6

To address this issue, we *stop* holding mm_users while the PASID is bound.
We already hold mm_count by virtue of the MMU notifier, and that can be
made to be sufficient.

It means that for a period during process exit, the fun part of mmput()
has happened and exit_mmap() has been called so the MM is basically
defunct. But the PGD still exists and the PASID is still bound to it.

During this period, we have to be very careful =E2=80=94 exit_mmap() doesn'=
t use
mm->mmap_sem because it doesn't expect anyone else to be touching the MM
(quite reasonably, since mm_users is zero). So we also need to fix the
fault handler to just report failure if mm_users is already zero, and to
temporarily bump mm_users while handling any faults.

Additionally, exit_mmap() calls mmu_notifier_release() *before* it tears
down the page tables, which is too early for us to flush the IOTLB for
this PASID. And __mmu_notifier_release() removes every notifier from the
list, so when exit_mmap() finally *does* tear down the mappings and
clear the page tables, we don't get notified. So we work around this by
clearing the PASID table entry in our MMU notifier release() callback.
That way, the hardware *can't* get any pages back from the page tables
before they get cleared.

Hardware designers have confirmed that the resulting 'PASID not present'
faults should be handled just as gracefully as 'page not present' faults,
the important criterion being that they don't perturb the operation for
any *other* PASID in the system.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
Cc: stable@vger.kernel.org
---
=C2=A0drivers/iommu/intel-svm.c | 33 +++++++++++++++++++++++++++------
=C2=A01 file changed, 27 insertions(+), 6 deletions(-)

diff --git a/drivers/iommu/intel-svm.c b/drivers/iommu/intel-svm.c
index 5046483..97a8189 100644
--- a/drivers/iommu/intel-svm.c
+++ b/drivers/iommu/intel-svm.c
@@ -249,12 +249,30 @@ static void intel_flush_pasid_dev(struct intel_svm *s=
vm, struct intel_svm_dev *s
=C2=A0static void intel_mm_release(struct mmu_notifier *mn, struct mm_struc=
t *mm)
=C2=A0{
=C2=A0	struct intel_svm *svm =3D container_of(mn, struct intel_svm, notifie=
r);
+	struct intel_svm_dev *sdev;
=C2=A0
+	/* This might end up being called from exit_mmap(), *before* the page
+	=C2=A0* tables are cleared. And __mmu_notifier_release() will delete us f=
rom
+	=C2=A0* the list of notifiers so that our invalidate_range() callback doe=
sn't
+	=C2=A0* get called when the page tables are cleared. So we need to protec=
t
+	=C2=A0* against hardware accessing those page tables.
+	=C2=A0*
+	=C2=A0* We do it by clearing the entry in the PASID table and then flushi=
ng
+	=C2=A0* the IOTLB and the PASID table caches. This might upset hardware;
+	=C2=A0* perhaps we'll want to point the PASID to a dummy PGD (like the ze=
ro
+	=C2=A0* page) so that we end up taking a fault that the hardware really
+	=C2=A0* *has* to handle gracefully without affecting other processes.
+	=C2=A0*/
=C2=A0	svm->iommu->pasid_table[svm->pasid].val =3D 0;
+	wmb();
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(sdev, &svm->devs, list) {
+		intel_flush_pasid_dev(svm, sdev, svm->pasid);
+		intel_flush_svm_range_dev(svm, sdev, 0, -1, 0, !svm->mm);
+	}
+	rcu_read_unlock();
=C2=A0
-	/* There's no need to do any flush because we can't get here if there
-	=C2=A0* are any devices left anyway. */
-	WARN_ON(!list_empty(&svm->devs));
=C2=A0}
=C2=A0
=C2=A0static const struct mmu_notifier_ops intel_mmuops =3D {
@@ -379,7 +397,6 @@ int intel_svm_bind_mm(struct device *dev, int *pasid, i=
nt flags, struct svm_dev_
=C2=A0				goto out;
=C2=A0			}
=C2=A0			iommu->pasid_table[svm->pasid].val =3D (u64)__pa(mm->pgd) | 1;
-			mm =3D NULL;
=C2=A0		} else
=C2=A0			iommu->pasid_table[svm->pasid].val =3D (u64)__pa(init_mm.pgd) | 1 =
| (1ULL << 11);
=C2=A0		wmb();
@@ -442,11 +459,11 @@ int intel_svm_unbind_mm(struct device *dev, int pasid=
)
=C2=A0				kfree_rcu(sdev, rcu);
=C2=A0
=C2=A0				if (list_empty(&svm->devs)) {
-					mmu_notifier_unregister(&svm->notifier, svm->mm);
=C2=A0
=C2=A0					idr_remove(&svm->iommu->pasid_idr, svm->pasid);
=C2=A0					if (svm->mm)
-						mmput(svm->mm);
+						mmu_notifier_unregister(&svm->notifier, svm->mm);
+
=C2=A0					/* We mandate that no page faults may be outstanding
=C2=A0					=C2=A0* for the PASID when intel_svm_unbind_mm() is called.
=C2=A0					=C2=A0* If that is not obeyed, subtle errors will happen.
@@ -551,6 +568,9 @@ static irqreturn_t prq_event_thread(int irq, void *d)
=C2=A0		=C2=A0* any faults on kernel addresses. */
=C2=A0		if (!svm->mm)
=C2=A0			goto bad_req;
+		/* If the mm is already defunct, don't handle faults. */
+		if (!atomic_inc_not_zero(&svm->mm->mm_users))
+			goto bad_req;
=C2=A0		down_read(&svm->mm->mmap_sem);
=C2=A0		vma =3D find_extend_vma(svm->mm, address);
=C2=A0		if (!vma || address < vma->vm_start)
@@ -567,6 +587,7 @@ static irqreturn_t prq_event_thread(int irq, void *d)
=C2=A0		result =3D QI_RESP_SUCCESS;
=C2=A0	invalid:
=C2=A0		up_read(&svm->mm->mmap_sem);
+		mmput(svm->mm);
=C2=A0	bad_req:
=C2=A0		/* Accounting for major/minor faults? */
=C2=A0		rcu_read_lock();
--=C2=A0
2.5.0

--=20
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

--=-gQSoAmSpHXo1uQkLFWWl
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
CQUxDxcNMTYwMTEzMjEzNTA1WjAjBgkqhkiG9w0BCQQxFgQULTocfmkFxwX+nAJBXQnvaWwF+5Mw
gaUGCSsGAQQBgjcQBDGBlzCBlDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0
ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMT
L1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBAgMN7zcwgacG
CyqGSIb3DQEJEAILMYGXoIGUMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRk
LjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMv
U3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0ECAw3vNzANBgkq
hkiG9w0BAQEFAASCAQAsOsPBoOJokj20jmSAAP+ElH6lw/NZJ1Rq9AEiyrz4rn6DVvuT79pp1/zZ
b8zoXUM1jSjK1NB+8zQBttMX63ksVE54F3s1UBjPVQ/dOd903O8RPbzK6avq/6ONozxsr+hsm9uF
EcXRYxNILwd95mOYI4rkTwQzSL9n4w4u3JP6payzmhsCqKM/E57c7S/WsKdTekAAxq/ORkAJOFgD
E5622oxj+NDHXdhZTZwnE0vZuvq0xPBdD00vavmhhbpH7ALbbenJBNnYiMge2v5jT5Z5T0MFJN76
GPzqoSqCqZzZRfCTmKxINodh72vD0rAF84pIfZ6kUW1aYh/YTfmZtEMcAAAAAAAA


--=-gQSoAmSpHXo1uQkLFWWl--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
