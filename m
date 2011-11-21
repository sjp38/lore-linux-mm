Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DA7776B0069
	for <linux-mm@kvack.org>; Sun, 20 Nov 2011 19:13:31 -0500 (EST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cyeoh@au1.ibm.com>;
	Mon, 21 Nov 2011 00:11:28 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAL0DGgf4800618
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 11:13:16 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAL0DGDA007190
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 11:13:16 +1100
Date: Mon, 21 Nov 2011 10:43:13 +1030
From: Christopher Yeoh <cyeoh@au1.ibm.com>
Subject: Re: Cross Memory Attach v3
Message-ID: <20111121104313.63c7f796@cyeoh-System-Product-Name>
In-Reply-To: <CAMuHMdWAhn7M8o0qY4pz3W1tyyKEcNY_YQL_6JuAPCcjL5vS1A@mail.gmail.com>
References: <20110719003537.16b189ae@lilo>
	<CAMuHMdWAhn7M8o0qY4pz3W1tyyKEcNY_YQL_6JuAPCcjL5vS1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-man@vger.kernel.org, linux-arch@vger.kernel.org, Linux/m68k <linux-m68k@vger.kernel.org>

Hi Geert,

On Sun, 20 Nov 2011 11:16:17 +0100
Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> On Mon, Jul 18, 2011 at 17:05, Christopher Yeoh <cyeoh@au1.ibm.com>
> wrote:
> > For arch maintainers there are some simple tests to be able to
> > quickly verify that the syscalls are working correctly here:
> 
> I'm wiring up these new syscalls on m68k.
> 
> > http://ozlabs.org/~cyeoh/cma/cma-test-20110718.tgz
> 
> The included README talks about:
> 
>     setup_process_readv_simple
>     setup_process_readv_iovec
>    setup_process_writev
> 
> while the actual test executables are called:
> 
>     setup_process_vm_readv_simple
>     setup_process_vm_readv_iovec
>     setup_process_vm_writev

Oops. Have fixed this and uploaded a new version

 http://ozlabs.org/~cyeoh/cma/cma-test-20111121.tgz

It also includes another minor change (see below)

> On m68k (ARAnyM), the first and third test succeed. The second one
> fails, though:
> 
> # Setting up target with num iovecs 10, test buffer size 100000
> Target process is setup
> Run the following to test:
> ./t_process_vm_readv_iovec 1574 10 0x800030b0 89 0x80003110 38302
> 0x8000c6b8 22423 0x80011e58 18864 0x80016810 583 0x80016a60 8054
> 0x800189e0 3417 0x80019740 368 0x800198b8 897 0x80019c40 7003
> 
> and in the other window:
> 
> # ./t_process_vm_readv_iovec 1574 10 0x800030b0 89 0x80003110 38302
> 0x8000c6b8 22423 0x80011e58 18864 0x80016810 583 0x80016a60 8054
> 0x800189e0 3417 0x80019740 368 0x800198b8 897 0x80019c40 7003
> copy_from_process failed: Invalid argument

That should say process_vm_readv instead of copy_from_process. The
error message is fixed in the just updated test.

> error code: 29
> #
> 
> Any suggestions?
> 

Given that the first and third tests succeed, I think the problem is
with the iovec parameters. The -EINVAL is most likely coming from
rw_copy_check_uvector. Any chance that something bad is
happening to lvec/liovcnt or rvec/riovcnt in the wireup? 

The iovecs are checked in process_vm_rw before the core of the
process_vm_readv/writev code is called so should be easy to confirm if
this is the problem.

The other couple of places where it could possibly come from is that
for some reason the flags parameter ends up being non zero or when
looking up the task the mm is NULL. But given that the first and second
tests succeed I think its unlikely that either of these is the cause.

Regards,

Chris
-- 
cyeoh@au.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
