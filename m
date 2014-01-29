Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id E2DE26B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 12:15:44 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id cm18so2830612qab.12
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 09:15:44 -0800 (PST)
Received: from mail-qc0-x22c.google.com (mail-qc0-x22c.google.com [2607:f8b0:400d:c01::22c])
        by mx.google.com with ESMTPS id c6si2236437qad.153.2014.01.29.09.15.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jan 2014 09:15:44 -0800 (PST)
Received: by mail-qc0-f172.google.com with SMTP id c9so3224910qcz.31
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 09:15:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALaYU_BZ8iuHnAgkss1wO7BK3qULgotYSpmX4nqX=uC+aTnddA@mail.gmail.com>
References: <CALaYU_BZ8iuHnAgkss1wO7BK3qULgotYSpmX4nqX=uC+aTnddA@mail.gmail.com>
From: Dermot McGahon <dmcgahon@waratek.com>
Date: Wed, 29 Jan 2014 17:15:23 +0000
Message-ID: <CALaYU_AA8fMLmp_Ng9Mhm0ztcXA0EHCxkU3p68tKs87G48NrOw@mail.gmail.com>
Subject: Fwd: CGroups and pthreads
Content-Type: multipart/mixed; boundary=001a11c2e904494d4804f11f1734
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--001a11c2e904494d4804f11f1734
Content-Type: text/plain; charset=ISO-8859-1

Forwarding a question that was first asked on cgroups mailing list.
Someone recommended asking here instead. We believe that we received
the correct answer, which is that cgroup memory subsystem charges
always to the leader of the Process Group rather than to the TID.
Could someone confirm that is definitely the case (testing does bear
that out). It does make sense to us, since who is to say which thread
should the process shared memory be accounted to. Unfortunately, in
our specific scenario, which is a JVM that generally allocated out of
the heap but occasionally loads native libraries that can allocate
using malloc() in known threads, we would have that information. But
we can see that in the general case it may not be that useful to
account per-thread.

Would appreciate any comments you may have.

-----------

Question originally posted to cgroups mailing list:

Is it possible to apply cgroup memory subsystem controls to threads
created with pthread_create() / clone or only tasks that have been
created using fork and exec?

In testing, we seem to be seeing that all allocations are accounted
for against the PPID / TGID and never the pthread_create()'d TID, even
though the TID is an LWP and can be seen using top (though RSS is
aggregate and global of course).

Attached is a simple test program used to print PID / TID and allocate
memory from a cloned TID. After setting breakpoints in child and
parent and setting up a cgroups hierarchy of 'parent' and 'child',
apply memory.limit_in_bytes and memory.memsw.limit_in_bytes to the
child cgroup only and adding the PID to the parent group and the TID
to the child group we see that behaviour.

Is that expected? I realise that the subsystems are all different but
what is confusing us slightly is that we have previously used the CPU
subsystem to set cpu_shares and adding LWP / TID's to individual
cgroups worked just fine for that

Am I misconfiguring somehow or is this a known difference between CPU
and MEMORY subsystems?

--001a11c2e904494d4804f11f1734
Content-Type: text/x-csrc; charset=US-ASCII; name="pthread_test.c"
Content-Disposition: attachment; filename="pthread_test.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hqxy6q1x0

I2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxzdHJpbmcuaD4KI2luY2x1ZGUgPHN0ZGxpYi5o
PgojaW5jbHVkZSA8c3lzL3N5c2NhbGwuaD4KCnZvaWQgdGhyZWFkX2Z1bmMoKQp7CiAgICBwcmlu
dGYoICJ0aHJlYWQgcGlkPSVkLCB0aHJlYWQgdGlkPSVkXG4iLCBnZXRwaWQoKSwgc3lzY2FsbCgg
U1lTX2dldHRpZCApICk7CgogICAgc2l6ZV90IG9uZV9odW5kcmVkX21iID0gMTAwICogMTAyNCAq
IDEwMjQ7CiAgICB2b2lkICogYWxsb2NhdGVkQ2h1bmsgPSBtYWxsb2MgKCBvbmVfaHVuZHJlZF9t
YiApOwogICAgbWVtc2V0KCBhbGxvY2F0ZWRDaHVuaywgMCwgb25lX2h1bmRyZWRfbWIgKTsKCiAg
ICBpZiAoIGFsbG9jYXRlZENodW5rID09IE5VTEwgKQogICAgewogICAgICAgIHByaW50ZigiY291
bGRuJ3QgYWxsb2NhdGVcbiIpOwogICAgfQogICAgZWxzZQogICAgewogICAgICAgIGludCB0aWQg
PSBzeXNjYWxsKCBTWVNfZ2V0dGlkICk7CiAgICAgICAgcHJpbnRmKCAiUElEOiAlZCwgVElEOiAl
ZCAtIGhhcyBhbGxvY2F0ZWQgMTAwbWJcbiIsIGdldHBpZCgpLCBzeXNjYWxsKCBTWVNfZ2V0dGlk
ICkgKTsKICAgIH0KCiAgICBzbGVlcCgxMDAwKTsKfQoKdm9pZCBtYWluKCkKewogICAgcHJpbnRm
KCAibWFpbiBwaWQ9JWQsIG1haW4gdGlkPSVkXG4iLCBnZXRwaWQoKSwgc3lzY2FsbCggU1lTX2dl
dHRpZCApICk7CgogICAgcHRocmVhZF90IHRocmVhZDE7CiAgICBwdGhyZWFkX2NyZWF0ZSggJnRo
cmVhZDEsIE5VTEwsICh2b2lkICopJnRocmVhZF9mdW5jLCBOVUxMKTsKCi8qICAgIHBpZF90IGNo
aWxkcGlkOwogICAgY2hpbGRwaWQgPSBmb3JrKCk7CgogICAgaWYgKCBjaGlsZHBpZCA+PSAwICkK
ICAgIHsKICAgICAgIGlmICggY2hpbGRwaWQgPT0gMCApCiAgICAgICB7CiAgICAgICAgICB0aHJl
YWRfZnVuYygpOyAvLyBjaGlsZAogICAgICAgfQogICAgICAgZWxzZQogICAgICAgewogICAgICAg
ICAgc2xlZXAoMTAwMCk7IC8vIHBhcmVudAogICAgICAgfQogICAgfQogICAgZWxzZQogICAgewog
ICAgICAgcGVycm9yKCJmb3JrIik7CiAgICAgICBleGl0KDApOwogICAgfSAqLwoKICAgIHNsZWVw
KDEwMDApOwp9Cgo=
--001a11c2e904494d4804f11f1734--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
