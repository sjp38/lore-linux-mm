Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2946B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 13:14:52 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id r101so28202552ioi.3
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 10:14:52 -0800 (PST)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id m75si6454877itb.51.2016.11.30.10.14.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 10:14:51 -0800 (PST)
Received: by mail-io0-x243.google.com with SMTP id j92so4097422ioi.0
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 10:14:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161130174713.lhvqgophhiupzwrm@merlins.org>
References: <48061a22-0203-de54-5a44-89773bff1e63@suse.cz> <CA+55aFweND3KoV=00onz0Y5W9ViFedd-nvfCuB+phorc=75tpQ@mail.gmail.com>
 <20161123063410.GB2864@dhcp22.suse.cz> <20161128072315.GC14788@dhcp22.suse.cz>
 <20161129155537.f6qgnfmnoljwnx6j@merlins.org> <20161129160751.GC9796@dhcp22.suse.cz>
 <20161129163406.treuewaqgt4fy4kh@merlins.org> <CA+55aFzNe=3e=cDig+vEzZS5jm2c6apPV4s5NKG4eYL4_jxQjQ@mail.gmail.com>
 <20161129174019.fywddwo5h4pyix7r@merlins.org> <CA+55aFz04aMBurHuME5A1NuhumMECD5iROhn06GB4=ceA+s6mw@mail.gmail.com>
 <20161130174713.lhvqgophhiupzwrm@merlins.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 30 Nov 2016 10:14:50 -0800
Message-ID: <CA+55aFzPQpvttSryRL3+EWeY7X+uFWOk2V+mM8JYm7ba+X1gHg@mail.gmail.com>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Content-Type: multipart/mixed; boundary=001a113ee5e455c442054288aec3
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc MERLIN <marc@merlins.org>, Kent Overstreet <kent.overstreet@gmail.com>, Tejun Heo <tj@kernel.org>, Jens Axboe <axboe@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

--001a113ee5e455c442054288aec3
Content-Type: text/plain; charset=UTF-8

On Wed, Nov 30, 2016 at 9:47 AM, Marc MERLIN <marc@merlins.org> wrote:
>
> I gave it a thought again, I think it is exactly the nasty situation you
> described.
> bcache takes I/O quickly while sending to SSD cache. SSD fills up, now
> bcache can't handle IO as quickly and has to hang until the SSD has been
> flushed to spinning rust drives.
> This actually is exactly the same as filling up the cache on a USB key
> and now you're waiting for slow writes to flash, is it not?

It does sound like you might hit exactly the same kind of situation, yes.

And the fact that you have dmcrypt running too just makes things pile
up more. All those IO's end up slowed down by the scheduling too.

Anyway, none of this seems new per se. I'm adding Kent and Jens to the
cc (Tejun already was), in the hope that maybe they have some idea how
to control the nasty worst-case behavior wrt workqueue lockup (it's
not really a "lockup", it looks like it's just hundreds of workqueues
all waiting for IO to complete and much too deep IO queues).

I think it's the traditional "throughput is much easier to measure and
improve" situation, where making queues big help some throughput
situation, but ends up causing chaos when things go south.

And I think your NMI watchdog then turns the "system is no longer
responsive" into an actual kernel panic.

> With your dirty ratio workaround, I was able to re-enable bcache and
> have it not fall over, but only barely. I recorded over a hundred
> workqueues in flight during the copy at some point (just not enough
> to actually kill the kernel this time).
>
> I've started a bcache followp on this here:
> http://marc.info/?l=linux-bcache&m=148052441423532&w=2
> http://marc.info/?l=linux-bcache&m=148052620524162&w=2
>
> A full traceback showing the pilup of requests is here:
> http://marc.info/?l=linux-bcache&m=147949497808483&w=2
>
> and there:
> http://pastebin.com/rJ5RKUVm
> (2 different ones but mostly the same result)

Tejun/Kent - any way to just limit the workqueue depth for bcache?
Because that really isn't helping, and things *will* time out and
cause those problems when you have hundreds of IO's queued on a disk
that likely as a write iops around ~100..

And I really wonder if we should do the "big hammer" approach to the
dirty limits on non-HIGHMEM machines too (approximate the
"vm_highmem_is_dirtyable" by just limiting global_dirtyable_memory()
to 1 GB).

That would make the default dirty limits be 100/200MB (for soft/hard
throttling), which really is much more reasonable than gigabytes and
gigabytes of dirty data.

Of course, no way do we do that during rc7..

                    Linus

--001a113ee5e455c442054288aec3
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iw590r8i0

IG1tL3BhZ2Utd3JpdGViYWNrLmMgfCA5ICsrKysrKysrLQogMSBmaWxlIGNoYW5nZWQsIDggaW5z
ZXJ0aW9ucygrKSwgMSBkZWxldGlvbigtKQoKZGlmZiAtLWdpdCBhL21tL3BhZ2Utd3JpdGViYWNr
LmMgYi9tbS9wYWdlLXdyaXRlYmFjay5jCmluZGV4IDQzOWNjNjNhZDkwMy4uMjZlY2JkZWNiODE1
IDEwMDY0NAotLS0gYS9tbS9wYWdlLXdyaXRlYmFjay5jCisrKyBiL21tL3BhZ2Utd3JpdGViYWNr
LmMKQEAgLTM1Miw2ICszNTIsMTAgQEAgc3RhdGljIHVuc2lnbmVkIGxvbmcgaGlnaG1lbV9kaXJ0
eWFibGVfbWVtb3J5KHVuc2lnbmVkIGxvbmcgdG90YWwpCiAjZW5kaWYKIH0KIAorLyogTGltaXQg
ZGlydHlhYmxlIG1lbW9yeSB0byAxR0IgKi8KKyNkZWZpbmUgUEFHRVNfSU5fR0IoeCkgKCh4KSA8
PCAoMzAgLSBQQUdFX1NISUZUKSkKKyNkZWZpbmUgTUFYX0RJUlRZQUJMRV9MT1dNRU1fUEFHRVMg
UEFHRVNfSU5fR0IoMSkKKwogLyoqCiAgKiBnbG9iYWxfZGlydHlhYmxlX21lbW9yeSAtIG51bWJl
ciBvZiBnbG9iYWxseSBkaXJ0eWFibGUgcGFnZXMKICAqCkBAIC0zNzMsOCArMzc3LDExIEBAIHN0
YXRpYyB1bnNpZ25lZCBsb25nIGdsb2JhbF9kaXJ0eWFibGVfbWVtb3J5KHZvaWQpCiAJeCArPSBn
bG9iYWxfbm9kZV9wYWdlX3N0YXRlKE5SX0lOQUNUSVZFX0ZJTEUpOwogCXggKz0gZ2xvYmFsX25v
ZGVfcGFnZV9zdGF0ZShOUl9BQ1RJVkVfRklMRSk7CiAKLQlpZiAoIXZtX2hpZ2htZW1faXNfZGly
dHlhYmxlKQorCWlmICghdm1faGlnaG1lbV9pc19kaXJ0eWFibGUpIHsKIAkJeCAtPSBoaWdobWVt
X2RpcnR5YWJsZV9tZW1vcnkoeCk7CisJCWlmICh4ID4gTUFYX0RJUlRZQUJMRV9MT1dNRU1fUEFH
RVMpCisJCQl4ID0gTUFYX0RJUlRZQUJMRV9MT1dNRU1fUEFHRVM7CisJfQogCiAJcmV0dXJuIHgg
KyAxOwkvKiBFbnN1cmUgdGhhdCB3ZSBuZXZlciByZXR1cm4gMCAqLwogfQo=
--001a113ee5e455c442054288aec3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
