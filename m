Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2196B0253
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 20:22:32 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id z19so8210697qtg.21
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 17:22:32 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f30si45573qta.422.2017.11.06.17.22.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 17:22:31 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vA71Lb6P019493
	for <linux-mm@kvack.org>; Mon, 6 Nov 2017 20:22:30 -0500
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2e2yy7gfvx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 06 Nov 2017 20:22:30 -0500
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Mon, 6 Nov 2017 20:22:28 -0500
Date: Mon, 6 Nov 2017 17:22:18 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v9 00/51] powerpc, mm: Memory Protection Keys
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
 <87efpbm706.fsf@mid.deneb.enyo.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87efpbm706.fsf@mid.deneb.enyo.de>
Message-Id: <20171107012218.GA5546@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fw@deneb.enyo.de>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de, linux-arch@vger.kernel.org, ebiederm@xmission.com, linux-doc@vger.kernel.org, x86@kernel.org, dave.hansen@intel.com, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, linux-kselftest@vger.kernel.org, bauerman@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, khandual@linux.vnet.ibm.com

On Mon, Nov 06, 2017 at 10:28:41PM +0100, Florian Weimer wrote:
> * Ram Pai:
> 
> > Testing:
> > -------
> > This patch series has passed all the protection key
> > tests available in the selftest directory.The
> > tests are updated to work on both x86 and powerpc.
> > The selftests have passed on x86 and powerpc hardware.
> 
> How do you deal with the key reuse problem?  Is it the same as x86-64,
> where it's quite easy to accidentally grant existing threads access to
> a just-allocated key, either due to key reuse or a changed init_pkru
> parameter?

I am not sure how on x86-64, two threads get allocated the same key
at the same time? the key allocation is guarded under the mmap_sem
semaphore. So there cannot be a race where two threads get allocated
the same key.

Can you point me to the issue, if it is already discussed somewhere?

As far as the semantics is concerned, a key allocated in one thread's
context has no meaning if used in some other threads context within the
same process.  The app should not try to re-use a key allocated in a
thread's context in some other threads's context.

> 
> What about siglongjmp from a signal handler?

On powerpc there is some relief.  the permissions on a key can be
modified from anywhere, including from the signal handler, and the
effect will be immediate.  You dont have to wait till the
signal handler returns for the key permissions to be restore.

also after return from the sigsetjmp();
possibly caused by siglongjmp(), the program can restore the permission
on any key.

Atleast that is my theory. Can you give me a testcase; if you have one
handy.

> 
>   <https://urldefense.proofpoint.com/v2/url?u=https-3A__sourceware.org_bugzilla_show-5Fbug.cgi-3Fid-3D22396&d=DwIBAg&c=jf_iaSHvJObTbx-siA1ZOg&r=m-UrKChQVkZtnPpjbF6YY99NbT8FBByQ-E-ygV8luxw&m=UmfbMQc2yyiSfzGDF9J2vFgiKDkVtkdf5xW3qdVeCVs&s=MuUgK3t4Ay8rjmIK7YgK94HZsp8IRG7pJwU6n-GnZn0&e=>
> 
> I wonder if it's possible to fix some of these things before the exact
> semantics of these interfaces are set in stone.

Will try.

RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
