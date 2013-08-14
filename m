Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 359456B0036
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 17:37:28 -0400 (EDT)
Received: by mail-ob0-f181.google.com with SMTP id dn14so3708obc.12
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 14:37:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130814203546.GA6200@kroah.com>
References: <1376508705-3188-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<20130814194348.GB10469@kroah.com>
	<520BE30D.3070401@sr71.net>
	<20130814203546.GA6200@kroah.com>
Date: Wed, 14 Aug 2013 14:37:26 -0700
Message-ID: <CAE9FiQUz6Ev0nbCoSbH7E=+zeJr6GKwR4B-z8+zJTRDPeF=jeA@mail.gmail.com>
Subject: Re: [RFC][PATCH] drivers: base: dynamic memory block creation
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: multipart/mixed; boundary=047d7b471da4f1197604e3ef29d7
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave@sr71.net>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

--047d7b471da4f1197604e3ef29d7
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Aug 14, 2013 at 1:35 PM, Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
> On Wed, Aug 14, 2013 at 01:05:33PM -0700, Dave Hansen wrote:
>> On 08/14/2013 12:43 PM, Greg Kroah-Hartman wrote:
>> > On Wed, Aug 14, 2013 at 02:31:45PM -0500, Seth Jennings wrote:
>> >> ppc64 has a normal memory block size of 256M (however sometimes as low
>> >> as 16M depending on the system LMB size), and (I think) x86 is 128M.  With
>> >> 1TB of RAM and a 256M block size, that's 4k memory blocks with 20 sysfs
>> >> entries per block that's around 80k items that need be created at boot
>> >> time in sysfs.  Some systems go up to 16TB where the issue is even more
>> >> severe.
>> >
>> > The x86 developers are working with larger memory sizes and they haven't
>> > seen the problem in this area, for them it's in other places, as I
>> > referred to in my other email.
>>
>> The SGI guys don't run normal distro kernels and don't turn on memory
>> hotplug, so they don't see this.  I do the same in my testing of
>> large-memory x86 systems to speed up my boots.  I'll go stick it back in
>> there and see if I can generate some numbers for a 1TB machine.
>>
>> But, the problem on x86 is at _worst_ 1/8 of the problem on ppc64 since
>> the SECTION_SIZE is so 8x bigger by default.
>>
>> Also, the cost of creating sections on ppc is *MUCH* higher than x86
>> when amortized across the number of pages that you're initializing.  A
>> section on ppc64 has to be created for each (2^24/2^16)=256 pages while
>> one on x86 is created for each (2^27/2^12)=32768 pages.
>>
>> Thus, x86 folks with our small pages and large sections tend to be
>> focused on per-page costs.  The ppc folks with their small sections and
>> larger pages tend to be focused on the per-section costs.
>
> Ah, thanks for the explaination, now it makes more sense why they are
> both optimizing in different places.

I had one local patch that sent before, it will probe block size for
generic x86_64.
set it to 2G looks more reasonable for system with 1T+ ram.

Also can we add block_size in that /sys directly so could generate
less entries ?

Thanks

Yinghai

--047d7b471da4f1197604e3ef29d7
Content-Type: application/octet-stream; name="block_size_x86_64.patch"
Content-Disposition: attachment; filename="block_size_x86_64.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hkd20u9n0

U3ViamVjdDogW1BBVENIIC12Ml0geDg2LCBtbTogUHJvYmUgbWVtb3J5IGJsb2NrIHNpemUgZm9y
IGdlbmVyaWMgeDg2IDY0Yml0CgpVc3VhbGx5IGlmIHRoZSBzeXN0ZW0gc3VwcG9ydCBtZW1vcnkg
cmVtYXBwaW5nIHRvIGdldCBiYWNrIG1lbW9yeSBmb3IgbW1pbwpyYW5nZSwgd2Ugd2lsbCBoYXZl
IDEyOE0gLi4uIDJHIGF0IHRoZSBlbmQuCgpUcnkgdG8gcHJvYmUgdGhhdCBzaXplLgoKU28gd2Ug
Y2FuIGdldCBsZXNzIGVudHJpZXMgaW4gL3N5cy9kZXZpY2VzL3N5c3RlbS9tZW1vcnkvCgotdjI6
IGRvbid0IHByb2JlIGl0IGV2ZXJ5IHRpbWUgd2hlbiAvc3lzLy4uL2Jsb2NrX3NpemVfYnl0ZSBp
cyBzaG93ZWQuLi4KClNpZ25lZC1vZmYtYnk6IFlpbmdoYWkgTHUgPHlpbmdoYWlAa2VybmVsLm9y
Zz4KCi0tLQogYXJjaC94ODYvbW0vaW5pdF82NC5jIHwgICAzNCArKysrKysrKysrKysrKysrKysr
KysrKysrKysrKystLS0tCiAxIGZpbGUgY2hhbmdlZCwgMzAgaW5zZXJ0aW9ucygrKSwgNCBkZWxl
dGlvbnMoLSkKCkluZGV4OiBsaW51eC0yLjYvYXJjaC94ODYvbW0vaW5pdF82NC5jCj09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT0KLS0tIGxpbnV4LTIuNi5vcmlnL2FyY2gveDg2L21tL2luaXRfNjQuYworKysgbGludXgtMi42
L2FyY2gveDg2L21tL2luaXRfNjQuYwpAQCAtMTI2MywxNyArMTI2Myw0MyBAQCBjb25zdCBjaGFy
ICphcmNoX3ZtYV9uYW1lKHN0cnVjdCB2bV9hcmVhCiAJcmV0dXJuIE5VTEw7CiB9CiAKLSNpZmRl
ZiBDT05GSUdfWDg2X1VWCi11bnNpZ25lZCBsb25nIG1lbW9yeV9ibG9ja19zaXplX2J5dGVzKHZv
aWQpCitzdGF0aWMgdW5zaWduZWQgbG9uZyBwcm9iZV9tZW1vcnlfYmxvY2tfc2l6ZSh2b2lkKQog
eworCS8qIHN0YXJ0IGZyb20gMmcgKi8KKwl1bnNpZ25lZCBsb25nIGJ6ID0gMVVMPDwzMTsKKwor
I2lmZGVmIENPTkZJR19YODZfVVYKIAlpZiAoaXNfdXZfc3lzdGVtKCkpIHsKIAkJcHJpbnRrKEtF
Uk5fSU5GTyAiVVY6IG1lbW9yeSBibG9jayBzaXplIDJHQlxuIik7CiAJCXJldHVybiAyVUwgKiAx
MDI0ICogMTAyNCAqIDEwMjQ7CiAJfQotCXJldHVybiBNSU5fTUVNT1JZX0JMT0NLX1NJWkU7Ci19
CiAjZW5kaWYKIAorCS8qIGxlc3MgdGhhbiA2NGcgaW5zdGFsbGVkICovCisJaWYgKChtYXhfcGZu
IDw8IFBBR0VfU0hJRlQpIDwgKDE2VUwgPDwgMzIpKQorCQlyZXR1cm4gTUlOX01FTU9SWV9CTE9D
S19TSVpFOworCisJLyogZ2V0IHRoZSB0YWlsIHNpemUgKi8KKwl3aGlsZSAoYnogPiBNSU5fTUVN
T1JZX0JMT0NLX1NJWkUpIHsKKwkJaWYgKCEoKG1heF9wZm4gPDwgUEFHRV9TSElGVCkgJiAoYnog
LSAxKSkpCisJCQlicmVhazsKKwkJYnogPj49IDE7CisJfQorCisJcHJpbnRrKEtFUk5fREVCVUcg
Im1lbW9yeSBibG9jayBzaXplIDogJWxkTUJcbiIsIGJ6ID4+IDIwKTsKKworCXJldHVybiBiejsK
K30KKworc3RhdGljIHVuc2lnbmVkIGxvbmcgbWVtb3J5X2Jsb2NrX3NpemVfcHJvYmVkOwordW5z
aWduZWQgbG9uZyBtZW1vcnlfYmxvY2tfc2l6ZV9ieXRlcyh2b2lkKQoreworCWlmICghbWVtb3J5
X2Jsb2NrX3NpemVfcHJvYmVkKQorCQltZW1vcnlfYmxvY2tfc2l6ZV9wcm9iZWQgPSBwcm9iZV9t
ZW1vcnlfYmxvY2tfc2l6ZSgpOworCisJcmV0dXJuIG1lbW9yeV9ibG9ja19zaXplX3Byb2JlZDsK
K30KKwogI2lmZGVmIENPTkZJR19TUEFSU0VNRU1fVk1FTU1BUAogLyoKICAqIEluaXRpYWxpc2Ug
dGhlIHNwYXJzZW1lbSB2bWVtbWFwIHVzaW5nIGh1Z2UtcGFnZXMgYXQgdGhlIFBNRCBsZXZlbC4K
--047d7b471da4f1197604e3ef29d7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
