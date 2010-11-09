Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9D71E6B0071
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 12:24:07 -0500 (EST)
Date: Tue, 9 Nov 2010 18:17:54 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/1][2nd resend] sys_unshare: remove the dead
	CLONE_THREAD/SIGHAND/VM code
Message-ID: <20101109171754.GB6971@redhat.com>
References: <20101105174142.GA19469@redhat.com> <20101105174343.GB19469@redhat.com> <20101109201742.BCA1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101109201742.BCA1.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Roland McGrath <roland@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, JANAK DESAI <janak@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On 11/09, KOSAKI Motohiro wrote:
>
> > -static void check_unshare_flags(unsigned long *flags_ptr)
> > +static int check_unshare_flags(unsigned long unshare_flags)
> >  {
> > +	if (unshare_flags & ~(CLONE_THREAD|CLONE_FS|CLONE_NEWNS|CLONE_SIGHAND|
> > +				CLONE_VM|CLONE_FILES|CLONE_SYSVSEM|
> > +				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWNET))
> > +		return -EINVAL;
>
> Please put WARN_ON_ONCE() explicitly. That's good way to find hidden
> user if exist and getting better bug report.

Perhaps... but this needs a separate change.

Please note that this check was simply moved from sys_unshare(), this
patch shouldn't have any visible effect.

Personally, I think it would be even better if, say, unshare(CLONE_THREAD)
returned -EINVAL unconditionally.

> And, I've reveied this patch and I've found no fault. but I will not put
> my ack because I think I haven't understand original intention perhaps.

Thanks!

IIRC, the main (only?) motivation for sys_unshare() was unshare_fs().
Most probably unshare_thread/vm were added as placeholders.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
