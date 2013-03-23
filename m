Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 531646B0002
	for <linux-mm@kvack.org>; Sat, 23 Mar 2013 16:37:38 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id 17so6068303iea.26
        for <linux-mm@kvack.org>; Sat, 23 Mar 2013 13:37:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130323152948.GA3036@sgi.com>
References: <20130318155619.GA18828@sgi.com>
	<20130321105516.GC18484@gmail.com>
	<alpine.DEB.2.02.1303211139110.3775@chino.kir.corp.google.com>
	<20130322072532.GC10608@gmail.com>
	<20130323152948.GA3036@sgi.com>
Date: Sat, 23 Mar 2013 13:37:37 -0700
Message-ID: <CAE9FiQUjVRUs02-ymmtO+5+SgqTWK8Ae6jJwD08uRbgR=eLJgw@mail.gmail.com>
Subject: Re: [patch] mm: speedup in __early_pfn_to_nid
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: multipart/mixed; boundary=20cf307f365cd6e95704d89d8aee
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russ Anderson <rja@sgi.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com

--20cf307f365cd6e95704d89d8aee
Content-Type: text/plain; charset=ISO-8859-1

On Sat, Mar 23, 2013 at 8:29 AM, Russ Anderson <rja@sgi.com> wrote:
> On Fri, Mar 22, 2013 at 08:25:32AM +0100, Ingo Molnar wrote:
> ------------------------------------------------------------
> When booting on a large memory system, the kernel spends
> considerable time in memmap_init_zone() setting up memory zones.
> Analysis shows significant time spent in __early_pfn_to_nid().
>
> The routine memmap_init_zone() checks each PFN to verify the
> nid is valid.  __early_pfn_to_nid() sequentially scans the list of
> pfn ranges to find the right range and returns the nid.  This does
> not scale well.  On a 4 TB (single rack) system there are 308
> memory ranges to scan.  The higher the PFN the more time spent
> sequentially spinning through memory ranges.
>
> Since memmap_init_zone() increments pfn, it will almost always be
> looking for the same range as the previous pfn, so check that
> range first.  If it is in the same range, return that nid.
> If not, scan the list as before.
>
> A 4 TB (single rack) UV1 system takes 512 seconds to get through
> the zone code.  This performance optimization reduces the time
> by 189 seconds, a 36% improvement.
>
> A 2 TB (single rack) UV2 system goes from 212.7 seconds to 99.8 seconds,
> a 112.9 second (53%) reduction.

Interesting. but only have 308 entries in memblock...

Did you try to extend memblock_search() to search nid back?
Something like attached patch. That should save more time.

>
> Signed-off-by: Russ Anderson <rja@sgi.com>
> ---
>  arch/ia64/mm/numa.c |   15 ++++++++++++++-
>  mm/page_alloc.c     |   15 ++++++++++++++-
>  2 files changed, 28 insertions(+), 2 deletions(-)
>
> Index: linux/mm/page_alloc.c
> ===================================================================
> --- linux.orig/mm/page_alloc.c  2013-03-19 16:09:03.736450861 -0500
> +++ linux/mm/page_alloc.c       2013-03-22 17:07:43.895405617 -0500
> @@ -4161,10 +4161,23 @@ int __meminit __early_pfn_to_nid(unsigne
>  {
>         unsigned long start_pfn, end_pfn;
>         int i, nid;
> +       /*
> +          NOTE: The following SMP-unsafe globals are only used early
> +          in boot when the kernel is running single-threaded.
> +        */
> +       static unsigned long last_start_pfn, last_end_pfn;
> +       static int last_nid;
> +
> +       if (last_start_pfn <= pfn && pfn < last_end_pfn)
> +               return last_nid;
>
>         for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid)
> -               if (start_pfn <= pfn && pfn < end_pfn)
> +               if (start_pfn <= pfn && pfn < end_pfn) {
> +                       last_start_pfn = start_pfn;
> +                       last_end_pfn = end_pfn;
> +                       last_nid = nid;
>                         return nid;
> +               }
>         /* This is a memory hole */
>         return -1;
>  }
> Index: linux/arch/ia64/mm/numa.c
> ===================================================================
> --- linux.orig/arch/ia64/mm/numa.c      2013-02-25 15:49:44.000000000 -0600
> +++ linux/arch/ia64/mm/numa.c   2013-03-22 16:09:44.662268239 -0500
> @@ -61,13 +61,26 @@ paddr_to_nid(unsigned long paddr)
>  int __meminit __early_pfn_to_nid(unsigned long pfn)
>  {
>         int i, section = pfn >> PFN_SECTION_SHIFT, ssec, esec;
> +       /*
> +          NOTE: The following SMP-unsafe globals are only used early
> +          in boot when the kernel is running single-threaded.
> +       */
> +       static unsigned long last_start_pfn, last_end_pfn;

last_ssec, last_esec?


> +       static int last_nid;
> +
> +       if (section >= last_ssec && section < last_esec)
> +               return last_nid;
>
>         for (i = 0; i < num_node_memblks; i++) {
>                 ssec = node_memblk[i].start_paddr >> PA_SECTION_SHIFT;
>                 esec = (node_memblk[i].start_paddr + node_memblk[i].size +
>                         ((1L << PA_SECTION_SHIFT) - 1)) >> PA_SECTION_SHIFT;
> -               if (section >= ssec && section < esec)
> +               if (section >= ssec && section < esec) {
> +                       last_ssec = ssec;
> +                       last_esec = esec;
> +                       last_nid = node_memblk[i].nid
>                         return node_memblk[i].nid;
> +               }
>         }
>
>         return -1;
>

also looks like you forget to put IA maintainers in the To list.

may just put ia64 part in separated patch?

Thanks

Yinghai

--20cf307f365cd6e95704d89d8aee
Content-Type: application/octet-stream; name="memblock_search_pfn_nid.patch"
Content-Disposition: attachment; filename="memblock_search_pfn_nid.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hen8ipgv0

LS0tCiBpbmNsdWRlL2xpbnV4L21lbWJsb2NrLmggfCAgICAyICsrCiBtbS9tZW1ibG9jay5jICAg
ICAgICAgICAgfCAgIDE4ICsrKysrKysrKysrKysrKysrKwogbW0vcGFnZV9hbGxvYy5jICAgICAg
ICAgIHwgICAxNCArKysrKysrKy0tLS0tLQogMyBmaWxlcyBjaGFuZ2VkLCAyOCBpbnNlcnRpb25z
KCspLCA2IGRlbGV0aW9ucygtKQoKSW5kZXg6IGxpbnV4LTIuNi9pbmNsdWRlL2xpbnV4L21lbWJs
b2NrLmgKPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PQotLS0gbGludXgtMi42Lm9yaWcvaW5jbHVkZS9saW51eC9tZW1ibG9j
ay5oCisrKyBsaW51eC0yLjYvaW5jbHVkZS9saW51eC9tZW1ibG9jay5oCkBAIC02MCw2ICs2MCw4
IEBAIGludCBtZW1ibG9ja19yZXNlcnZlKHBoeXNfYWRkcl90IGJhc2UsIHAKIHZvaWQgbWVtYmxv
Y2tfdHJpbV9tZW1vcnkocGh5c19hZGRyX3QgYWxpZ24pOwogCiAjaWZkZWYgQ09ORklHX0hBVkVf
TUVNQkxPQ0tfTk9ERV9NQVAKK2ludCBtZW1ibG9ja19zZWFyY2hfcGZuX25pZCh1bnNpZ25lZCBs
b25nIHBmbiwgdW5zaWduZWQgbG9uZyAqc3RhcnRfcGZuLAorCQkJICAgIHVuc2lnbmVkIGxvbmcg
ICplbmRfcGZuKTsKIHZvaWQgX19uZXh0X21lbV9wZm5fcmFuZ2UoaW50ICppZHgsIGludCBuaWQs
IHVuc2lnbmVkIGxvbmcgKm91dF9zdGFydF9wZm4sCiAJCQkgIHVuc2lnbmVkIGxvbmcgKm91dF9l
bmRfcGZuLCBpbnQgKm91dF9uaWQpOwogCkluZGV4OiBsaW51eC0yLjYvbW0vbWVtYmxvY2suYwo9
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09Ci0tLSBsaW51eC0yLjYub3JpZy9tbS9tZW1ibG9jay5jCisrKyBsaW51eC0yLjYv
bW0vbWVtYmxvY2suYwpAQCAtOTEwLDYgKzkxMCwyNCBAQCBpbnQgX19pbml0X21lbWJsb2NrIG1l
bWJsb2NrX2lzX21lbW9yeShwCiAJcmV0dXJuIG1lbWJsb2NrX3NlYXJjaCgmbWVtYmxvY2subWVt
b3J5LCBhZGRyKSAhPSAtMTsKIH0KIAorI2lmZGVmIENPTkZJR19IQVZFX01FTUJMT0NLX05PREVf
TUFQCitpbnQgX19pbml0X21lbWJsb2NrIG1lbWJsb2NrX3NlYXJjaF9wZm5fbmlkKHVuc2lnbmVk
IGxvbmcgcGZuLAorCQkJIHVuc2lnbmVkIGxvbmcgKnN0YXJ0X3BmbiwgdW5zaWduZWQgbG9uZyAq
ZW5kX3BmbikKK3sKKwlzdHJ1Y3QgbWVtYmxvY2tfdHlwZSAqdHlwZSA9ICZtZW1ibG9jay5tZW1v
cnk7CisJaW50IG1pZCA9IG1lbWJsb2NrX3NlYXJjaCh0eXBlLCAocGh5c19hZGRyX3QpcGZuIDw8
IFBBR0VfU0hJRlQpOworCisJaWYgKG1pZCA9PSAtMSkKKwkJcmV0dXJuIC0xOworCisJKnN0YXJ0
X3BmbiA9IHR5cGUtPnJlZ2lvbnNbbWlkXS5iYXNlID4+IFBBR0VfU0hJRlQ7CisJKmVuZF9wZm4g
PSAodHlwZS0+cmVnaW9uc1ttaWRdLmJhc2UgKyB0eXBlLT5yZWdpb25zW21pZF0uc2l6ZSkKKwkJ
CT4+IFBBR0VfU0hJRlQ7CisKKwlyZXR1cm4gdHlwZS0+cmVnaW9uc1ttaWRdLm5pZDsKK30KKyNl
bmRpZgorCiAvKioKICAqIG1lbWJsb2NrX2lzX3JlZ2lvbl9tZW1vcnkgLSBjaGVjayBpZiBhIHJl
Z2lvbiBpcyBhIHN1YnNldCBvZiBtZW1vcnkKICAqIEBiYXNlOiBiYXNlIG9mIHJlZ2lvbiB0byBj
aGVjawpJbmRleDogbGludXgtMi42L21tL3BhZ2VfYWxsb2MuYwo9PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09Ci0tLSBsaW51
eC0yLjYub3JpZy9tbS9wYWdlX2FsbG9jLmMKKysrIGxpbnV4LTIuNi9tbS9wYWdlX2FsbG9jLmMK
QEAgLTQxNjAsMTMgKzQxNjAsMTUgQEAgaW50IF9fbWVtaW5pdCBpbml0X2N1cnJlbnRseV9lbXB0
eV96b25lKAogaW50IF9fbWVtaW5pdCBfX2Vhcmx5X3Bmbl90b19uaWQodW5zaWduZWQgbG9uZyBw
Zm4pCiB7CiAJdW5zaWduZWQgbG9uZyBzdGFydF9wZm4sIGVuZF9wZm47Ci0JaW50IGksIG5pZDsK
KwlpbnQgbmlkOwogCi0JZm9yX2VhY2hfbWVtX3Bmbl9yYW5nZShpLCBNQVhfTlVNTk9ERVMsICZz
dGFydF9wZm4sICZlbmRfcGZuLCAmbmlkKQotCQlpZiAoc3RhcnRfcGZuIDw9IHBmbiAmJiBwZm4g
PCBlbmRfcGZuKQotCQkJcmV0dXJuIG5pZDsKLQkvKiBUaGlzIGlzIGEgbWVtb3J5IGhvbGUgKi8K
LQlyZXR1cm4gLTE7CisJbmlkID0gbWVtYmxvY2tfc2VhcmNoX3Bmbl9uaWQocGZuLCAmc3RhcnRf
cGZuLCAmZW5kX3Bmbik7CisKKwlpZiAobmlkICE9IC0xKSB7CisJLyogc2F2ZSBzdGFydF9wZm4s
IGFuZCBlbmRfcGZuID8qLworCX0KKworCXJldHVybiBuaWQ7CiB9CiAjZW5kaWYgLyogQ09ORklH
X0hBVkVfQVJDSF9FQVJMWV9QRk5fVE9fTklEICovCiAK
--20cf307f365cd6e95704d89d8aee--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
