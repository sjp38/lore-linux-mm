Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f177.google.com (mail-ve0-f177.google.com [209.85.128.177])
	by kanga.kvack.org (Postfix) with ESMTP id 578FC6B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 15:33:17 -0400 (EDT)
Received: by mail-ve0-f177.google.com with SMTP id sa20so1705298veb.36
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 12:33:17 -0700 (PDT)
Received: from mail-ve0-x235.google.com (mail-ve0-x235.google.com [2607:f8b0:400c:c01::235])
        by mx.google.com with ESMTPS id sc7si374663vdc.49.2014.04.23.12.33.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Apr 2014 12:33:16 -0700 (PDT)
Received: by mail-ve0-f181.google.com with SMTP id oy12so1677231veb.26
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 12:33:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140423184145.GH17824@quack.suse.cz>
References: <1398057630.19682.38.camel@pasglop>
	<CA+55aFwWHBtihC3w9E4+j4pz+6w7iTnYhTf4N3ie15BM9thxLQ@mail.gmail.com>
	<53558507.9050703@zytor.com>
	<CA+55aFxGm6J6N=4L7exLUFMr1_siNGHpK=wApd9GPCH1=63PPA@mail.gmail.com>
	<53559F48.8040808@intel.com>
	<CA+55aFwDtjA4Vp0yt0K5x6b6sAMtcn=61SEnOOs_En+3UXNpuA@mail.gmail.com>
	<CA+55aFzFxBDJ2rWo9DggdNsq-qBCr11OVXnm64jx04KMSVCBAw@mail.gmail.com>
	<20140422075459.GD11182@twins.programming.kicks-ass.net>
	<CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com>
	<alpine.LSU.2.11.1404221847120.1759@eggly.anvils>
	<20140423184145.GH17824@quack.suse.cz>
Date: Wed, 23 Apr 2014 12:33:15 -0700
Message-ID: <CA+55aFwm9BT4ecXF7dD+OM0-+1Wz5vd4ts44hOkS8JdQ74SLZQ@mail.gmail.com>
Subject: Re: Dirty/Access bits vs. page content
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/mixed; boundary=e89a8fb2078ed2b06004f7bacd2b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

--e89a8fb2078ed2b06004f7bacd2b
Content-Type: text/plain; charset=UTF-8

On Wed, Apr 23, 2014 at 11:41 AM, Jan Kara <jack@suse.cz> wrote:
>
> Now I'm not sure how to fix Linus' patches. For all I care we could just
> rip out pte dirty bit handling for file mappings. However last time I
> suggested this you corrected me that tmpfs & ramfs need this. I assume this
> is still the case - however, given we unconditionally mark the page dirty
> for write faults, where exactly do we need this?

Honza, you're missing the important part: it does not matter one whit
that we unconditionally mark the page dirty, when we do it *early*,
and it can be then be marked clean before it's actually clean!

The problem is that page cleaning can clean the page when there are
still writers dirtying the page. Page table tear-down removes the
entry from the page tables, but it's still there in the TLB on other
CPU's. So other CPU's are possibly writing to the page, when
clear_page_dirty_for_io() has marked it clean (because it didn't see
the page table entries that got torn down, and it hasn't seen the
dirty bit in the page yet).

I'm including Dave Hansen's "racewrite.c" with his commentary:

 "This is a will-it-scale test-case which handles all the thread creation
  and CPU binding for me: https://github.com/antonblanchard/will-it-scale
  .  Just stick the test case in tests/.  I also loopback-mounted a ramfs
  file as an ext4 filesystem on /mnt to make sure the writeback could
  happen fast.

  This reproduces the bug pretty darn quickly and with as few as 4 threads
  running like this:  ./racewrite_threads -t 4 -s 999"

and

 "It reproduces in about 5 seconds on my 4770 on an unpatched kernel.  It
  also reproduces on a _normal_ filesystem and doesn't apparently need the
  loopback-mounted ext4 ramfs file that I was trying before."

so this can actually be triggered.

              Linus

--e89a8fb2078ed2b06004f7bacd2b
Content-Type: text/x-csrc; charset=US-ASCII; name="racewrite.c"
Content-Disposition: attachment; filename="racewrite.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hud0mhpw0

I2RlZmluZSBfR05VX1NPVVJDRQojZGVmaW5lIF9YT1BFTl9TT1VSQ0UgNTAwCiNpbmNsdWRlIDxz
Y2hlZC5oPgojaW5jbHVkZSA8c3lzL21tYW4uaD4KI2luY2x1ZGUgPGZjbnRsLmg+CiNpbmNsdWRl
IDxzdGRpby5oPgojaW5jbHVkZSA8c3RkbGliLmg+CiNpbmNsdWRlIDx1bmlzdGQuaD4KI2luY2x1
ZGUgPHN0cmluZy5oPgojaW5jbHVkZSA8YXNzZXJ0Lmg+CgojZGVmaW5lIEJVRkxFTiA0MDk2Cgpz
dGF0aWMgY2hhciB3aXN0bXBmaWxlW10gPSAiL21udC93aWxsaXRzY2FsZS5YWFhYWFgiOwoKY2hh
ciAqdGVzdGNhc2VfZGVzY3JpcHRpb24gPSAiU2FtZSBmaWxlIHB3cml0ZSI7CgpjaGFyICpidWY7
CiNkZWZpbmUgRklMRV9TSVpFICg0MDk2KjEwMjQpCnZvaWQgdGVzdGNhc2VfcHJlcGFyZSh2b2lk
KQp7CglpbnQgZmQgPSBta3N0ZW1wKHdpc3RtcGZpbGUpOwoKCWFzc2VydChmZCA+PSAwKTsKCWFz
c2VydChwd3JpdGUoZmQsICJYIiwgMSwgRklMRV9TSVpFLTEpID09IDEpOwoJYnVmID0gbW1hcChO
VUxMLCBGSUxFX1NJWkUsIFBST1RfUkVBRHxQUk9UX1dSSVRFLAoJCQkgICAgICAgTUFQX1NIQVJF
RCwgZmQsIDApOwoJYXNzZXJ0KGJ1ZiAhPSAodm9pZCAqKS0xKTsKCWNsb3NlKGZkKTsKfQoKdm9p
ZCB0ZXN0Y2FzZSh1bnNpZ25lZCBsb25nIGxvbmcgKml0ZXJhdGlvbnMpCnsKCWludCBjcHUgPSBz
Y2hlZF9nZXRjcHUoKTsKCWludCBmZCA9IG9wZW4od2lzdG1wZmlsZSwgT19SRFdSKTsKCW9mZl90
IG9mZnNldCA9IHNjaGVkX2dldGNwdSgpICogQlVGTEVOOwoJbG9uZyBjb3VudGVyID0gMDsKCWxv
bmcgY291bnRlcnJlYWQgPSAwOwoJbG9uZyAqY291bnRlcmJ1ZiA9ICh2b2lkICopJmJ1ZltvZmZz
ZXRdOwoKCXByaW50Zigib2Zmc2V0OiAlbGRcbiIsIG9mZnNldCk7CglwcmludGYoIiAgICAgICBi
dWY6ICVwXG4iLCBidWYpOwoJcHJpbnRmKCJjb3VudGVyYnVmOiAlcFxuIiwgY291bnRlcmJ1Zik7
Cglhc3NlcnQoZmQgPj0gMCk7CgoJd2hpbGUgKDEpIHsKCQlpbnQgcmV0OwoJCWlmIChjcHUgPT0g
MSkgewoJCQlyZXQgPSBtYWR2aXNlKGJ1ZiwgRklMRV9TSVpFLCBNQURWX0RPTlRORUVEKTsKCQkJ
Y29udGludWU7CgkJfQoJCgkJKmNvdW50ZXJidWYgPSBjb3VudGVyOwoJCXBvc2l4X2ZhZHZpc2Uo
ZmQsIG9mZnNldCwgQlVGTEVOLCBQT1NJWF9GQURWX0RPTlRORUVEKTsKCQlyZXQgPSBwcmVhZChm
ZCwgJmNvdW50ZXJyZWFkLCBzaXplb2YoY291bnRlcnJlYWQpLCBvZmZzZXQpOwoJCWFzc2VydChy
ZXQgPT0gc2l6ZW9mKGNvdW50ZXJyZWFkKSk7CgoJCWlmIChjb3VudGVycmVhZCAhPSBjb3VudGVy
KSB7CgkJCXByaW50ZigiY3B1OiAlZFxuIiwgY3B1KTsKCQkJcHJpbnRmKCIgICAgY291bnRlciAl
bGRcbiIsIGNvdW50ZXIpOwoJCQlwcmludGYoImNvdW50ZXJyZWFkICVsZFxuIiwgY291bnRlcnJl
YWQpOwoJCQlwcmludGYoIipjb3VudGVyYnVmICVsZFxuIiwgKmNvdW50ZXJidWYpOwoJCQl3aGls
ZSgxKTsKCQl9CgkJY291bnRlcisrOwkKCQkoKml0ZXJhdGlvbnMpKys7Cgl9Cn0KCnZvaWQgdGVz
dGNhc2VfY2xlYW51cCh2b2lkKQp7Cgl1bmxpbmsod2lzdG1wZmlsZSk7Cn0K
--e89a8fb2078ed2b06004f7bacd2b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
