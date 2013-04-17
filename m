Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id B7FCF6B0092
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 10:10:37 -0400 (EDT)
Date: Wed, 17 Apr 2013 09:10:35 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH] mm: mmu_notifier: re-fix freed page still mapped in
 secondary MMU
Message-ID: <20130417141035.GA29872@sgi.com>
References: <516CF235.4060103@linux.vnet.ibm.com>
 <20130416093131.GJ3658@sgi.com>
 <516D275C.8040406@linux.vnet.ibm.com>
 <20130416112553.GM3658@sgi.com>
 <20130416114322.GN3658@sgi.com>
 <516D4D08.9020602@linux.vnet.ibm.com>
 <20130416180835.GY3658@sgi.com>
 <516E0F1E.5090805@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <516E0F1E.5090805@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Gleb Natapov <gleb@redhat.com>, Avi Kivity <avi.kivity@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, KVM <kvm@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Apr 17, 2013 at 10:55:26AM +0800, Xiao Guangrong wrote:
> On 04/17/2013 02:08 AM, Robin Holt wrote:
> > On Tue, Apr 16, 2013 at 09:07:20PM +0800, Xiao Guangrong wrote:
> >> On 04/16/2013 07:43 PM, Robin Holt wrote:
> >>> Argh.  Taking a step back helped clear my head.
> >>>
> >>> For the -stable releases, I agree we should just go with your
> >>> revert-plus-hlist_del_init_rcu patch.  I will give it a test
> >>> when I am in the office.
> >>
> >> Okay. Wait for your test report. Thank you in advance.
> >>
> >>>
> >>> For the v3.10 release, we should work on making this more
> >>> correct and completely documented.
> >>
> >> Better document is always welcomed.
> >>
> >> Double call ->release is not bad, like i mentioned it in the changelog:
> >>
> >> it is really rare (e.g, can not happen on kvm since mmu-notify is unregistered
> >> after exit_mmap()) and the later call of multiple ->release should be
> >> fast since all the pages have already been released by the first call.
> >>
> >> But, of course, it's great if you have a _light_ way to avoid this.
> > 
> > Getting my test environment set back up took longer than I would have liked.
> > 
> > Your patch passed.  I got no NULL-pointer derefs.
> 
> Thanks for your test again.
> 
> > 
> > How would you feel about adding the following to your patch?
> 
> I prefer to make these changes as a separate patch, this change is the
> improvement, please do not mix it with bugfix.

I think your "improvement" classification is a bit deceiving.  My previous
patch fixed the bug in calling release multiple times.  Your patch without
this will reintroduce that buggy behavior.  Just because the bug is already
worked around by KVM does not mean it is not a bug.

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
