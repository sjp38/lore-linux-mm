Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3E44D6B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 17:19:25 -0500 (EST)
Received: by oixx65 with SMTP id x65so141597807oix.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 14:19:25 -0800 (PST)
Received: from g2t2355.austin.hp.com (g2t2355.austin.hp.com. [15.217.128.54])
        by mx.google.com with ESMTPS id zf5si8955614obb.63.2015.11.23.14.19.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 14:19:24 -0800 (PST)
Message-ID: <1448316903.19320.46.camel@hpe.com>
Subject: Re: [PATCH] mm: Fix mmap MAP_POPULATE for DAX pmd mapping
From: Toshi Kani <toshi.kani@hpe.com>
Date: Mon, 23 Nov 2015 15:15:03 -0700
In-Reply-To: <CAPcyv4gOrc_heKtBRZiiKeywo6Dn2JSTtfKgvse_1siyvd7kTg@mail.gmail.com>
References: <1448309082-20851-1-git-send-email-toshi.kani@hpe.com>
	 <CAPcyv4gOrc_heKtBRZiiKeywo6Dn2JSTtfKgvse_1siyvd7kTg@mail.gmail.com>
Content-Type: multipart/mixed; boundary="=-UwOidSeeVOF63N1Bvr6o"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, mauricio.porto@hpe.com, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


--=-UwOidSeeVOF63N1Bvr6o
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Mon, 2015-11-23 at 12:53 -0800, Dan Williams wrote:
> On Mon, Nov 23, 2015 at 12:04 PM, Toshi Kani <toshi.kani@hpe.com> wrote:
> > The following oops was observed when mmap() with MAP_POPULATE
> > pre-faulted pmd mappings of a DAX file.  follow_trans_huge_pmd()
> > expects that a target address has a struct page.
> > 
> >   BUG: unable to handle kernel paging request at ffffea0012220000
> >   follow_trans_huge_pmd+0xba/0x390
> >   follow_page_mask+0x33d/0x420
> >   __get_user_pages+0xdc/0x800
> >   populate_vma_page_range+0xb5/0xe0
> >   __mm_populate+0xc5/0x150
> >   vm_mmap_pgoff+0xd5/0xe0
> >   SyS_mmap_pgoff+0x1c1/0x290
> >   SyS_mmap+0x1b/0x30
> > 
> > Fix it by making the PMD pre-fault handling consistent with PTE.
> > After pre-faulted in faultin_page(), follow_page_mask() calls
> > follow_trans_huge_pmd(), which is changed to call follow_pfn_pmd()
> > for VM_PFNMAP or VM_MIXEDMAP.  follow_pfn_pmd() handles FOLL_TOUCH
> > and returns with -EEXIST.
> 
> As of 4.4.-rc2 DAX pmd mappings are disabled.  So we have time to do
> something more comprehensive in 4.5.

Yes, I noticed during my testing that I could not use pmd...

> > Reported-by: Mauricio Porto <mauricio.porto@hpe.com>
> > Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Matthew Wilcox <willy@linux.intel.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> > ---
> >  mm/huge_memory.c |   34 ++++++++++++++++++++++++++++++++++
> >  1 file changed, 34 insertions(+)
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index d5b8920..f56e034 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> [..]
> > @@ -1288,6 +1315,13 @@ struct page *follow_trans_huge_pmd(struct
> > vm_area_struct *vma,
> >         if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
> >                 goto out;
> > 
> > +       /* pfn map does not have a struct page */
> > +       if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP)) {
> > +               ret = follow_pfn_pmd(vma, addr, pmd, flags);
> > +               page = ERR_PTR(ret);
> > +               goto out;
> > +       }
> > +
> >         page = pmd_page(*pmd);
> >         VM_BUG_ON_PAGE(!PageHead(page), page);
> >         if (flags & FOLL_TOUCH) {
> 
> I think it is already problematic that dax pmd mappings are getting
> confused with transparent huge pages.  

We had the same issue with dax pte mapping [1], and this change extends the pfn
map handling to pmd.  So, this problem is not specific to pmd.

[1] https://lkml.org/lkml/2015/6/23/181

> They're more closely related to
> a hugetlbfs pmd mappings in that they are mapping an explicit
> allocation.  I have some pending patches to address this dax-pmd vs
> hugetlb-pmd vs thp-pmd classification that I will post shortly.

Not sure which way is better, but I am certainly interested in your changes.

> By the way, I'm collecting DAX pmd regression tests [1], is this just
> a simple crash upon using MAP_POPULATE?
> 
> [1]: https://github.com/pmem/ndctl/blob/master/lib/test-dax-pmd.c

Yes, this issue is easy to reproduce with MAP_POPULATE.  In case it helps,
attached are the test I used for testing the patches.  Sorry, the code is messy
since it was only intended for my internal use...

 - The test was originally written for the pte change [1] and comments in
test.sh (ex. mlock fail, ok) reflect the results without the pte change.
 - For the pmd test, I modified test-mmap.c to call posix_memalign() before
mmap().  By calling free(), the 2MB-aligned address from posix_memalign() can be
used for mmap().  This keeps the mmap'd address aligned on 2MB.
 - I created test file(s) with dd (i.e. all blocks written) in my test.
 - The other infinite loop issue (fixed by my other patch) was found by the test
case with option "-LMSr".

Thanks,
-Toshi

--=-UwOidSeeVOF63N1Bvr6o
Content-Type: application/x-shellscript; name="test.sh"
Content-Disposition: attachment; filename="test.sh"
Content-Transfer-Encoding: base64

c2V0IC14IAp1bW91bnQgL21udC9wbWVtMAptb3VudCAvbW50L3BtZW0wCgojZWNobyAnZmlsZSBt
bS9ndXAuYyArcCcgPiAvc3lzL2tlcm5lbC9kZWJ1Zy9keW5hbWljX2RlYnVnL2NvbnRyb2wKI2Vj
aG8gJ2ZpbGUgbW0vaHVnZV9tZW1vcnkuYyArcCcgPiAvc3lzL2tlcm5lbC9kZWJ1Zy9keW5hbWlj
X2RlYnVnL2NvbnRyb2wKI2VjaG8gJ2ZpbGUgbW0vbWVtb3J5LmMgK3AnID4gL3N5cy9rZXJuZWwv
ZGVidWcvZHluYW1pY19kZWJ1Zy9jb250cm9sCiNlY2hvICdmaWxlIGZzL2RheC5jICtwJyA+IC9z
eXMva2VybmVsL2RlYnVnL2R5bmFtaWNfZGVidWcvY29udHJvbAoKIyMjIyAzMksgIyMjIwojIFNI
QVJFRAojLi90ZXN0LW1tYXAgLU1yd3BzCSMgbWxvY2ssIHBvcHVsYXRlLCBzaGFyZWQgKG1sb2Nr
IGZhaWwpCiMuL3Rlc3QtbW1hcCAtQXJ3cHMJIyBtbG9ja2FsbCwgcG9wdWxhdGUsIHNoYXJlZAoj
Li90ZXN0LW1tYXAgLVJNcnBzCSMgcmVhZC1vbmx5LCBtbG9jaywgcG9wdWxhdGUsIHNoYXJlZCAo
bWxvY2sgZmFpbCkKIy4vdGVzdC1tbWFwIC1yd3BzCSMgcG9wbHVhdGUsIHNoYXJlZCAocG9wbHVh
dGUgbm8gZWZmZWN0KQojLi90ZXN0LW1tYXAgLVJycHMJIyByZWFkLW9ubHkgcG9wbHVhdGUsIHNo
YXJlZCAocG9wbHVhdGUgbm8gZWZmZWN0KQojLi90ZXN0LW1tYXAgLU1yd3MJIyBtbG9jaywgc2hh
cmVkIChtbG9jayBmYWlsKQojLi90ZXN0LW1tYXAgLVJNcnMJIyByZWFkLW9ubHksIG1sb2NrLCBz
aGFyZWQgKG1sb2NrIGZhaWwpCiMuL3Rlc3QtbW1hcCAtcndzCSMgc2hhcmVkIChvaykKIy4vdGVz
dC1tbWFwIC1ScnMJIyByZWFkLW9ubHksIHNoYXJlZCAob2spCgojIFBSSVZBVEUKIy4vdGVzdC1t
bWFwIC1NcndwCSMgbWxvY2ssIHBvcHVsYXRlLCBwcml2YXRlIChvaykKIy4vdGVzdC1tbWFwIC1S
TXJwCSMgcmVhZC1vbmx5LCBtbG9jaywgcG9wdWxhdGUsIHByaXZhdGUgKG1sb2NrIGZhaWwpCiMu
L3Rlc3QtbW1hcCAtcndwCSMgcG9wdWxhdGUsIHByaXZhdGUgKG9rKQojLi90ZXN0LW1tYXAgLVJy
cAkjIHJlYWQtb25seSwgcG9wdWxhdGUsIHByaXZhdGUgKHBvcHVsYXRlIG5vIGVmZmVjdCkKIy4v
dGVzdC1tbWFwIC1NcncJIyBtbG9jaywgcHJpdmF0ZSAob2spCiMuL3Rlc3QtbW1hcCAtUk1yCSMg
cmVhZC1vbmx5LCBtbG9jaywgcHJpdmF0ZSAobWxvY2sgZmFpbCkKIy4vdGVzdC1tbWFwIC1NU3IJ
IyBwcml2YXRlLCByZWFkIGJlZm9yZSBtbG9jayAob2spCiMuL3Rlc3QtbW1hcCAtcncJIyBwcml2
YXRlIChvaykKIy4vdGVzdC1tbWFwIC1ScgkjIHJlYWQtb25seSwgcHJpdmF0ZSAob2spCgojIyMj
IDRHICMjIyMKIyBTSEFSRUQKIy4vdGVzdC1tbWFwIC1MTXJ3cHMJIyBtbG9jaywgcG9wdWxhdGUs
IHNoYXJlZCAobWxvY2sgZmFpbCkKIy4vdGVzdC1tbWFwIC1MQXJ3cHMJIyBtbG9ja2FsbCwgcG9w
dWxhdGUsIHNoYXJlZAojLi90ZXN0LW1tYXAgLUxSTXJwcwkjIHJlYWQtb25seSwgbWxvY2ssIHBv
cHVsYXRlLCBzaGFyZWQgKG1sb2NrIGZhaWwpCiMuL3Rlc3QtbW1hcCAtTHJ3cHMJIyBwb3BsdWF0
ZSwgc2hhcmVkIChwb3BsdWF0ZSBubyBlZmZlY3QpCiMuL3Rlc3QtbW1hcCAtTFJycHMJIyByZWFk
LW9ubHkgcG9wbHVhdGUsIHNoYXJlZCAocG9wbHVhdGUgbm8gZWZmZWN0KQojLi90ZXN0LW1tYXAg
LUxNcndzCSMgbWxvY2ssIHNoYXJlZCAobWxvY2sgZmFpbCkKIy4vdGVzdC1tbWFwIC1MUk1ycwkj
IHJlYWQtb25seSwgbWxvY2ssIHNoYXJlZCAobWxvY2sgZmFpbCkKIy4vdGVzdC1tbWFwIC1Mcndz
CSMgc2hhcmVkIChvaykKIy4vdGVzdC1tbWFwIC1MUnJzCSMgcmVhZC1vbmx5LCBzaGFyZWQgKG9r
KQoKIyBQUklWQVRFCiMuL3Rlc3QtbW1hcCAtTE1yd3AJIyBtbG9jaywgcG9wdWxhdGUsIHByaXZh
dGUgKG9rKQojLi90ZXN0LW1tYXAgLUxSTXJwCSMgcmVhZC1vbmx5LCBtbG9jaywgcG9wdWxhdGUs
IHByaXZhdGUgKG1sb2NrIGZhaWwpCiMuL3Rlc3QtbW1hcCAtTHJ3cAkjIHBvcHVsYXRlLCBwcml2
YXRlIChvaykKIy4vdGVzdC1tbWFwIC1MUnJwCSMgcmVhZC1vbmx5LCBwb3B1bGF0ZSwgcHJpdmF0
ZSAocG9wdWxhdGUgbm8gZWZmZWN0KQojLi90ZXN0LW1tYXAgLUxNcncJIyBtbG9jaywgcHJpdmF0
ZSAob2spCiMuL3Rlc3QtbW1hcCAtTFJNcgkjIHJlYWQtb25seSwgbWxvY2ssIHByaXZhdGUgKG1s
b2NrIGZhaWwpCiMuL3Rlc3QtbW1hcCAtTE1TcgkjIHByaXZhdGUsIHJlYWQgYmVmb3JlIG1sb2Nr
IChvaykKIy4vdGVzdC1tbWFwIC1McncJIyBwcml2YXRlIChvaykKIy4vdGVzdC1tbWFwIC1MUnIJ
IyByZWFkLW9ubHksIHByaXZhdGUgKG9rKQoKI2VjaG8gJ2ZpbGUgbW0vZ3VwLmMgLXAnID4gL3N5
cy9rZXJuZWwvZGVidWcvZHluYW1pY19kZWJ1Zy9jb250cm9sCiNlY2hvICdmaWxlIG1tL2h1Z2Vf
bWVtb3J5LmMgLXAnID4gL3N5cy9rZXJuZWwvZGVidWcvZHluYW1pY19kZWJ1Zy9jb250cm9sCiNl
Y2hvICdmaWxlIG1tL21lbW9yeS5jIC1wJyA+IC9zeXMva2VybmVsL2RlYnVnL2R5bmFtaWNfZGVi
dWcvY29udHJvbAojZWNobyAnZmlsZSBmcy9kYXguYyAtcCcgPiAvc3lzL2tlcm5lbC9kZWJ1Zy9k
eW5hbWljX2RlYnVnL2NvbnRyb2wK


--=-UwOidSeeVOF63N1Bvr6o
Content-Disposition: attachment; filename="test-mmap.c"
Content-Type: text/x-csrc; name="test-mmap.c"; charset="UTF-8"
Content-Transfer-Encoding: base64

I2luY2x1ZGUgPHN5cy90eXBlcy5oPgojaW5jbHVkZSA8c3lzL3N0YXQuaD4KI2luY2x1ZGUgPHN5
cy9tbWFuLmg+CiNpbmNsdWRlIDxzeXMvdGltZS5oPgojaW5jbHVkZSA8c3RyaW5nLmg+CiNpbmNs
dWRlIDxmY250bC5oPgojaW5jbHVkZSA8c3RkaW8uaD4KI2luY2x1ZGUgPHN0ZGxpYi5oPgojaW5j
bHVkZSA8dW5pc3RkLmg+CgojZGVmaW5lIE1CKGEpCQkoKGEpICogMTAyNFVMICogMTAyNFVMKQoK
c3RhdGljIHN0cnVjdCB0aW1ldmFsIHN0YXJ0X3R2LCBzdG9wX3R2OwoKLy8gQ2FsY3VsYXRlIHRo
ZSBkaWZmZXJlbmNlIGJldHdlZW4gdHdvIHRpbWUgdmFsdWVzLgp2b2lkIHR2c3ViKHN0cnVjdCB0
aW1ldmFsICp0ZGlmZiwgc3RydWN0IHRpbWV2YWwgKnQxLCBzdHJ1Y3QgdGltZXZhbCAqdDApCnsK
CXRkaWZmLT50dl9zZWMgPSB0MS0+dHZfc2VjIC0gdDAtPnR2X3NlYzsKCXRkaWZmLT50dl91c2Vj
ID0gdDEtPnR2X3VzZWMgLSB0MC0+dHZfdXNlYzsKCWlmICh0ZGlmZi0+dHZfdXNlYyA8IDApCgkJ
dGRpZmYtPnR2X3NlYy0tLCB0ZGlmZi0+dHZfdXNlYyArPSAxMDAwMDAwOwp9CgovLyBTdGFydCB0
aW1pbmcgbm93Lgp2b2lkIHN0YXJ0KCkKewoJKHZvaWQpIGdldHRpbWVvZmRheSgmc3RhcnRfdHYs
IChzdHJ1Y3QgdGltZXpvbmUgKikgMCk7Cn0KCi8vIFN0b3AgdGltaW5nIGFuZCByZXR1cm4gcmVh
bCB0aW1lIGluIG1pY3Jvc2Vjb25kcy4KdW5zaWduZWQgbG9uZyBsb25nIHN0b3AoKQp7CglzdHJ1
Y3QgdGltZXZhbCB0ZGlmZjsKCgkodm9pZCkgZ2V0dGltZW9mZGF5KCZzdG9wX3R2LCAoc3RydWN0
IHRpbWV6b25lICopIDApOwoJdHZzdWIoJnRkaWZmLCAmc3RvcF90diwgJnN0YXJ0X3R2KTsKCXJl
dHVybiAodGRpZmYudHZfc2VjICogMTAwMDAwMCArIHRkaWZmLnR2X3VzZWMpOwp9Cgp2b2lkIHRl
c3Rfd3JpdGUodW5zaWduZWQgbG9uZyAqcCwgc2l6ZV90IHNpemUpCnsKCWludCBpOwoJdW5zaWdu
ZWQgbG9uZyAqd3AsIHRtcDsKCXVuc2lnbmVkIGxvbmcgbG9uZyB0aW1ldmFsOwoKCXN0YXJ0KCk7
Cglmb3IgKGk9MCwgd3A9cDsgaTwoc2l6ZS9zaXplb2Yod3ApKTsgaSsrKQoJCSp3cCsrID0gMTsK
CXRpbWV2YWwgPSBzdG9wKCk7CglwcmludGYoIldyaXRlOiAlMTBsbHUgdXNlY1xuIiwgdGltZXZh
bCk7Cn0KCnZvaWQgdGVzdF9yZWFkKHVuc2lnbmVkIGxvbmcgKnAsIHNpemVfdCBzaXplKQp7Cglp
bnQgaTsKCXVuc2lnbmVkIGxvbmcgKndwLCB0bXA7Cgl1bnNpZ25lZCBsb25nIGxvbmcgdGltZXZh
bDsKCglzdGFydCgpOwoJZm9yIChpPTAsIHdwPXA7IGk8KHNpemUvc2l6ZW9mKHdwKSk7IGkrKykK
CQl0bXAgPSAqd3ArKzsKCXRpbWV2YWwgPSBzdG9wKCk7CglwcmludGYoIlJlYWQgOiAlMTBsbHUg
dXNlY1xuIiwgdGltZXZhbCk7Cn0KCmludCBtYWluKGludCBhcmdjLCBjaGFyICoqYXJndikKewoJ
aW50IGZkLCBpLCBvcHQsIHJldDsKCWludCBvZmxhZ3MsIG1wcm90LCBtZmxhZ3MgPSAwOwoJaW50
IGlzX3JlYWRfb25seSA9IDAsIGlzX21sb2NrID0gMCwgaXNfbWxvY2thbGwgPSAwOwoJaW50IG1s
b2NrX3NraXAgPSAwLCByZWFkX3Rlc3QgPSAwLCB3cml0ZV90ZXN0ID0gMDsKCXZvaWQgKm1wdHIg
PSBOVUxMOwoJdW5zaWduZWQgbG9uZyAqcDsKCXN0cnVjdCBzdGF0IHN0YXQ7CglzaXplX3Qgc2l6
ZSwgY3B5X3NpemU7Cgljb25zdCBjaGFyICpmaWxlX25hbWUgPSBOVUxMOwoKCXdoaWxlICgob3B0
ID0gZ2V0b3B0KGFyZ2MsIGFyZ3YsICJMUk1TQXBzcnciKSkgIT0gLTEpIHsKCQlzd2l0Y2ggKG9w
dCkgewoJCWNhc2UgJ0wnOgoJCQlmaWxlX25hbWUgPSAiL21udC9wbWVtMC80R2ZpbGUiOwoJCQli
cmVhazsKCQljYXNlICdSJzoKCQkJcHJpbnRmKCI+IG1tYXA6IHJlYWQtb25seVxuIik7CgkJCWlz
X3JlYWRfb25seSA9IDE7CgkJCWJyZWFrOwoJCWNhc2UgJ00nOgoJCQlwcmludGYoIj4gbWxvY2tc
biIpOwoJCQlpc19tbG9jayA9IDE7CgkJCWJyZWFrOwoJCWNhc2UgJ1MnOgoJCQlwcmludGYoIj4g
bWxvY2sgLSBza2lwIGZpcnN0IGl0ZVxuIik7CgkJCW1sb2NrX3NraXAgPSAxOwoJCQlicmVhazsK
CQljYXNlICdBJzoKCQkJcHJpbnRmKCI+IG1sb2NrYWxsXG4iKTsKCQkJaXNfbWxvY2thbGwgPSAx
OwoJCQlicmVhazsKCQljYXNlICdwJzoKCQkJcHJpbnRmKCI+IE1BUF9QT1BVTEFURVxuIik7CgkJ
CW1mbGFncyB8PSBNQVBfUE9QVUxBVEU7CgkJCWJyZWFrOwoJCWNhc2UgJ3MnOgoJCQlwcmludGYo
Ij4gTUFQX1NIQVJFRFxuIik7CgkJCW1mbGFncyB8PSBNQVBfU0hBUkVEOwoJCQlicmVhazsKCQlj
YXNlICdyJzoKCQkJcHJpbnRmKCI+IHJlYWQtdGVzdFxuIik7CgkJCXJlYWRfdGVzdCA9IDE7CgkJ
CWJyZWFrOwoJCWNhc2UgJ3cnOgoJCQlwcmludGYoIj4gd3JpdGUtdGVzdFxuIik7CgkJCXdyaXRl
X3Rlc3QgPSAxOwoJCQlicmVhazsKCQl9Cgl9CgoJaWYgKCFmaWxlX25hbWUpIHsKCQlmaWxlX25h
bWUgPSAiL21udC9wbWVtMS8zMktmaWxlIjsKCX0KCglpZiAoIShtZmxhZ3MgJiBNQVBfU0hBUkVE
KSkgewoJCXByaW50ZigiPiBNQVBfUFJJVkFURVxuIik7CgkJbWZsYWdzIHw9IE1BUF9QUklWQVRF
OwoJfQoKCWlmIChpc19yZWFkX29ubHkpIHsKCQlvZmxhZ3MgPSBPX1JET05MWTsKCQltcHJvdCA9
IFBST1RfUkVBRDsKCX0gZWxzZSB7CgkJb2ZsYWdzID0gT19SRFdSOwoJCW1wcm90ID0gUFJPVF9S
RUFEfFBST1RfV1JJVEU7Cgl9CgoJZmQgPSBvcGVuKGZpbGVfbmFtZSwgb2ZsYWdzKTsKCWlmIChm
ZCA9PSAtMSkgewoJCXBlcnJvcigib3BlbiBmYWlsZWQiKTsKCQlleGl0KDEpOwoJfQoKCXJldCA9
IGZzdGF0KGZkLCAmc3RhdCk7CglpZiAocmV0IDwgMCkgewoJCXBlcnJvcigiZnN0YXQgZmFpbGVk
Iik7CgkJZXhpdCgxKTsKCX0KCXNpemUgPSBzdGF0LnN0X3NpemU7CgoJcHJpbnRmKCI+IG9wZW4g
JXMgc2l6ZSAweCV4IGZsYWdzIDB4JXhcbiIsIGZpbGVfbmFtZSwgc2l6ZSwgb2ZsYWdzKTsKCgly
ZXQgPSBwb3NpeF9tZW1hbGlnbigmbXB0ciwgTUIoMiksIHNpemUpOwoJaWYgKHJldCA9PTApCgkJ
ZnJlZShtcHRyKTsKCglwcmludGYoIj4gbW1hcCBtcHJvdCAweCV4IGZsYWdzIDB4JXhcbiIsIG1w
cm90LCBtZmxhZ3MpOwoJcCA9IG1tYXAobXB0ciwgc2l6ZSwgbXByb3QsIG1mbGFncywgZmQsIDB4
MCk7CglpZiAoIXApIHsKCQlwZXJyb3IoIm1tYXAgZmFpbGVkIik7CgkJZXhpdCgxKTsKCX0KCWlm
ICgobG9uZyB1bnNpZ25lZClwICYgKE1CKDIpLTEpKQoJCXByaW50ZigiPiBtbWFwOiBOT1QgMk1C
IGFsaWduZWQ6IDB4JXBcbiIsIHApOwoJZWxzZQoJCXByaW50ZigiPiBtbWFwOiAyTUIgYWxpZ25l
ZDogMHglcFxuIiwgcCk7CgojaWYgMAkvKiBTSVpFIExJTUlUICovCglpZiAoc2l6ZSA+PSBNQigy
KSkKCQljcHlfc2l6ZSA9IE1CKDMyKTsKCWVsc2UKI2VuZGlmCgkJY3B5X3NpemUgPSBzaXplOwoK
CWZvciAoaT0wOyBpPDM7IGkrKykgewoKCQlpZiAoaXNfbWxvY2sgJiYgIW1sb2NrX3NraXApIHsK
CQkJcHJpbnRmKCI+IG1sb2NrIDB4JXBcbiIsIHApOwoJCQlyZXQgPSBtbG9jayhwLCBzaXplKTsK
CQkJaWYgKHJldCA8IDApIHsKCQkJCXBlcnJvcigibWxvY2sgZmFpbGVkIik7CgkJCQlleGl0KDEp
OwoJCQl9CgkJfSBlbHNlIGlmIChpc19tbG9ja2FsbCkgewoJCQlwcmludGYoIj4gbWxvY2thbGxc
biIpOwoJCQlyZXQgPSBtbG9ja2FsbChNQ0xfQ1VSUkVOVHxNQ0xfRlVUVVJFKTsKCQkJaWYgKHJl
dCA8IDApIHsKCQkJCXBlcnJvcigibWxvY2thbGwgZmFpbGVkIik7CgkJCQlleGl0KDEpOwoJCQl9
CgkJfQoKCQlwcmludGYoIj09PT09ICVkID09PT09XG4iLCBpKzEpOwoJCWlmICh3cml0ZV90ZXN0
KQoJCQl0ZXN0X3dyaXRlKHAsIGNweV9zaXplKTsKCQlpZiAocmVhZF90ZXN0KQoJCQl0ZXN0X3Jl
YWQocCwgY3B5X3NpemUpOwoKCQlpZiAoaXNfbWxvY2sgJiYgIW1sb2NrX3NraXApIHsKCQkJcHJp
bnRmKCI+IG11bmxvY2sgMHglcFxuIiwgcCk7CgkJCXJldCA9IG11bmxvY2socCwgc2l6ZSk7CgkJ
CWlmIChyZXQgPCAwKSB7CgkJCQlwZXJyb3IoIm11bmxvY2sgZmFpbGVkIik7CgkJCQlleGl0KDEp
OwoJCQl9CgkJfSBlbHNlIGlmIChpc19tbG9ja2FsbCkgewoJCQlwcmludGYoIj4gbXVubG9ja2Fs
bFxuIik7CgkJCXJldCA9IG11bmxvY2thbGwoKTsKCQkJaWYgKHJldCA8IDApIHsKCQkJCXBlcnJv
cigibXVubG9ja2FsbCBmYWlsZWQiKTsKCQkJCWV4aXQoMSk7CgkJCX0KCQl9CgoJCS8qIHNraXAs
IGlmIHJlcXVlc3RlZCwgb25seSB0aGUgZmlyc3QgaXRlcmF0aW9uICovCgkJbWxvY2tfc2tpcCA9
IDA7Cgl9CgoJcHJpbnRmKCI+IG11bm1hcCAweCVwXG4iLCBwKTsKCW11bm1hcChwLCBzaXplKTsK
fQo=


--=-UwOidSeeVOF63N1Bvr6o--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
