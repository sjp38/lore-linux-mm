Date: Tue, 5 Sep 2000 11:55:32 +0100 (BST)
From: Mark Hemment <markhe@veritas.com>
Subject: Re: stack overflow
In-Reply-To: <Pine.LNX.4.21.0009041219241.1639-100000@saturn.homenet>
Message-ID: <Pine.LNX.4.21.0009051147230.15193-200000@alloc>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="0-1003887953-968151332=:15193"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tigran Aivazian <tigran@veritas.com>
Cc: Matti Aarnio <matti.aarnio@zmailer.org>, Zeshan Ahmad <zeshan_uet@yahoo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--0-1003887953-968151332=:15193
Content-Type: TEXT/PLAIN; charset=US-ASCII

Hi,

  A quick look indicates what could be the problem.
  In my original, the code assumes that all general purpose slabs below
"bufctl_limit" where suitable for bufctl allocation (look at a 2.2.x
version, in kmem_cache_sizes_init() I have a state variable called
"found").
  The modified code (by who?), which now uses "offslab_limit", removes
the assumption, which could very well be causing the stack overflow; the
code now breaks the comment "Inc off-slab bufctl limit until the ceiling
is hit" as it has no ceiling.
  Bringing back the state variable will close at least one door.

  I've attached a completely untested (and uncompiled) patch.

  If this doesn't fix it, I'll look deeper.

Mark



On Mon, 4 Sep 2000, Tigran Aivazian wrote:

> On Mon, 4 Sep 2000, Matti Aarnio wrote:
> > > when the function kmem_cache_sizes_init is called in
> > > /init/main.c The exact place where the stack overflow
> > > occurs is in the function kmem_cache_slabmgmt in
> > > /mm/slab.c
> > > 
> > > Is there any way to change the stack size in Kernel?
> > > Can the change in stack size simply solve this Kernel
> > > stack overflow problem?
> > 
> > 	That is indicative that somewhere along the path
> > 	you are:  a) recursin
> 
> looking at the code, it seems in theory possible to recurse via
> kmem_cache_alloc()->kmem_cache_grow()->kmem_cache_slabmgmt()->kmem_cache_alloc() but
> I thought Mark invented offslab_limit to prevent this.
> 
> Maybe decreasing offslab_limit can help? Defer to Mark...
> 
> Regards,
> Tigran
> 

--0-1003887953-968151332=:15193
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="slab.patch"
Content-ID: <Pine.LNX.4.21.0009051155320.15193@alloc>
Content-Description: slab.patch
Content-Disposition: attachment; filename="slab.patch"
Content-Transfer-Encoding: BASE64

LS0tIHNsYWIuYy4wMAlUdWUgU2VwICA1IDEyOjQ5OjE2IDIwMDANCisrKyBz
bGFiLmMJVHVlIFNlcCAgNSAxMjo1MTozNiAyMDAwDQpAQCAtNDI0LDE0ICs0
MjQsMTcgQEANCiAgKi8NCiB2b2lkIF9faW5pdCBrbWVtX2NhY2hlX3NpemVz
X2luaXQodm9pZCkNCiB7DQorCXVuc2lnbmVkIGludAlsaW1pdF9mb3VuZDsN
CiAJY2FjaGVfc2l6ZXNfdCAqc2l6ZXMgPSBjYWNoZV9zaXplczsNCiAJY2hh
ciBuYW1lWzIwXTsNCisNCiAJLyoNCiAJICogRnJhZ21lbnRhdGlvbiByZXNp
c3RhbmNlIG9uIGxvdyBtZW1vcnkgLSBvbmx5IHVzZSBiaWdnZXINCiAJICog
cGFnZSBvcmRlcnMgb24gbWFjaGluZXMgd2l0aCBtb3JlIHRoYW4gMzJNQiBv
ZiBtZW1vcnkuDQogCSAqLw0KIAlpZiAobnVtX3BoeXNwYWdlcyA+ICgzMiA8
PCAyMCkgPj4gUEFHRV9TSElGVCkNCiAJCXNsYWJfYnJlYWtfZ2ZwX29yZGVy
ID0gQlJFQUtfR0ZQX09SREVSX0hJOw0KKwlsaW1pdF9mb3VuZCA9IDA7DQog
CWRvIHsNCiAJCS8qIEZvciBwZXJmb3JtYW5jZSwgYWxsIHRoZSBnZW5lcmFs
IGNhY2hlcyBhcmUgTDEgYWxpZ25lZC4NCiAJCSAqIFRoaXMgc2hvdWxkIGJl
IHBhcnRpY3VsYXJseSBiZW5lZmljaWFsIG9uIFNNUCBib3hlcywgYXMgaXQN
CkBAIC00NDYsOSArNDQ5LDEyIEBADQogCQl9DQogDQogCQkvKiBJbmMgb2Zm
LXNsYWIgYnVmY3RsIGxpbWl0IHVudGlsIHRoZSBjZWlsaW5nIGlzIGhpdC4g
Ki8NCi0JCWlmICghKE9GRl9TTEFCKHNpemVzLT5jc19jYWNoZXApKSkgew0K
LQkJCW9mZnNsYWJfbGltaXQgPSBzaXplcy0+Y3Nfc2l6ZS1zaXplb2Yoc2xh
Yl90KTsNCi0JCQlvZmZzbGFiX2xpbWl0IC89IDI7DQorCQlpZiAobGltaXRf
Zm91bmQgPT0gMCkgew0KKwkJCWlmICghKE9GRl9TTEFCKHNpemVzLT5jc19j
YWNoZXApKSkgew0KKwkJCQlvZmZzbGFiX2xpbWl0ID0gc2l6ZXMtPmNzX3Np
emUtc2l6ZW9mKHNsYWJfdCk7DQorCQkJCW9mZnNsYWJfbGltaXQgLz0gMjsN
CisJCQl9IGVsc2UNCisJCQkJbGltaXRfZm91bmQgPSAxOw0KIAkJfQ0KIAkJ
c3ByaW50ZihuYW1lLCAic2l6ZS0lWmQoRE1BKSIsc2l6ZXMtPmNzX3NpemUp
Ow0KIAkJc2l6ZXMtPmNzX2RtYWNhY2hlcCA9IGttZW1fY2FjaGVfY3JlYXRl
KG5hbWUsIHNpemVzLT5jc19zaXplLCAwLA0K
--0-1003887953-968151332=:15193--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
