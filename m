Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 63A2E6B02E8
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 17:40:09 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id m6so649622qtc.6
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 14:40:09 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r18si1670094qkl.26.2017.11.07.14.40.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 14:40:07 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vA7MdiHX004762
	for <linux-mm@kvack.org>; Tue, 7 Nov 2017 17:40:06 -0500
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2e3gnfetbp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 07 Nov 2017 17:40:05 -0500
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Tue, 7 Nov 2017 17:40:03 -0500
Date: Tue, 7 Nov 2017 14:39:53 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v9 00/51] powerpc, mm: Memory Protection Keys
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
 <87efpbm706.fsf@mid.deneb.enyo.de>
 <20171107012218.GA5546@ram.oc3035372033.ibm.com>
 <87h8u6lf27.fsf@mid.deneb.enyo.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <87h8u6lf27.fsf@mid.deneb.enyo.de>
Message-Id: <20171107223953.GB5546@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fw@deneb.enyo.de>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de, linux-arch@vger.kernel.org, ebiederm@xmission.com, linux-doc@vger.kernel.org, x86@kernel.org, dave.hansen@intel.com, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, linux-kselftest@vger.kernel.org, bauerman@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, khandual@linux.vnet.ibm.com

On Tue, Nov 07, 2017 at 08:32:16AM +0100, Florian Weimer wrote:
> * Ram Pai:
> 
> > On Mon, Nov 06, 2017 at 10:28:41PM +0100, Florian Weimer wrote:
> >> * Ram Pai:
> >> 
> >> > Testing:
> >> > -------
> >> > This patch series has passed all the protection key
> >> > tests available in the selftest directory.The
> >> > tests are updated to work on both x86 and powerpc.
> >> > The selftests have passed on x86 and powerpc hardware.
> >> 
> >> How do you deal with the key reuse problem?  Is it the same as x86-64,
> >> where it's quite easy to accidentally grant existing threads access to
> >> a just-allocated key, either due to key reuse or a changed init_pkru
> >> parameter?
> >
> > I am not sure how on x86-64, two threads get allocated the same key
> > at the same time? the key allocation is guarded under the mmap_sem
> > semaphore. So there cannot be a race where two threads get allocated
> > the same key.
> 
> The problem is a pkey_alloc/pthread_create/pkey_free/pkey_alloc
> sequence.  The pthread_create call makes the new thread inherit the
> access rights of the current thread, but then the key is deallocated.
> Reallocation of the same key will have that thread retain its access
> rights, which is IMHO not correct.

(Dave Hansen: please correct me if I miss-speak below)

As per the current semantics of sys_pkey_free(); the way I understand it,
the calling thread is saying disassociate me from this key. Other
threads continue to be associated with the key and could continue to
get key-faults, but this calling thread will not get key-faults on that
key any more.

Also the key should not get reallocated till all the threads in the process
have disassocated from the key; by calling sys_pkey_free().

>From that point of view, I think there is a bug in the implementation of
pkey on x86 and now on powerpc aswell.

> 
> > Can you point me to the issue, if it is already discussed somewhere?
> 
> See a??MPK: pkey_free and key reusea?? on various lists (including
> linux-mm and linux-arch).
> 
> It has a test case attached which demonstrates the behavior.
> 
> > As far as the semantics is concerned, a key allocated in one thread's
> > context has no meaning if used in some other threads context within the
> > same process.  The app should not try to re-use a key allocated in a
> > thread's context in some other threads's context.
> 
> Uh-oh, that's not how this feature works on x86-64 at all.  There, the
> keys are a process-global resource.  Treating them per-thread
> seriously reduces their usefulness.

Sorry. I was not thinking right. Let me restate.

A key is a global resource, but the permissions on a key is
local to a thread. For eg: the same key could disable
access on a page for one thread, while it could disable write
on the same page on another thread.

> 
> >> What about siglongjmp from a signal handler?
> >
> > On powerpc there is some relief.  the permissions on a key can be
> > modified from anywhere, including from the signal handler, and the
> > effect will be immediate.  You dont have to wait till the
> > signal handler returns for the key permissions to be restore.
> 
> My concern is that the signal handler knows nothing about protection
> keys, but the current x86-64 semantics will cause it to clobber the
> access rights of the current thread.
> 
> > also after return from the sigsetjmp();
> > possibly caused by siglongjmp(), the program can restore the permission
> > on any key.
> 
> So that's not really an option.
> 
> > Atleast that is my theory. Can you give me a testcase; if you have one
> > handy.
> 
> The glibc patch I posted under the a??MPK: pkey_free and key reusea??
> thread covers this, too.

thanks. will try the test case with my kernel patches. But, on
powerpc one can change the permissions on the key in the signal handler
which takes into effect immediately, there should not be a bug
in powerpc.

x86 has this requirement where it has to return from the signal handler
back to the kernel in order to change the permission on a key,
it can cause issues with longjump.

RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
