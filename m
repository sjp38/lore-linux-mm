Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 136736B0073
	for <linux-mm@kvack.org>; Tue, 21 May 2013 17:13:19 -0400 (EDT)
Date: Tue, 21 May 2013 18:13:00 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [RFC PATCH 02/02] swapon: add "cluster-discard" support
Message-ID: <20130521211300.GE20178@optiplex.redhat.com>
References: <cover.1369092449.git.aquini@redhat.com>
 <398ace0dd3ca1283372b3aad3fceeee59f6897d7.1369084886.git.aquini@redhat.com>
 <519AC7B3.5060902@gmail.com>
 <20130521102648.GB11774@x2.net.home>
 <519BD640.4040102@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <519BD640.4040102@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Karel Zak <kzak@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, shli@kernel.org, jmoyer@redhat.com, riel@redhat.com, lwoodman@redhat.com, mgorman@suse.de

Karel, Motohiro,

Thanks a lot for your time reviewing this patch and providing me with valuable
feedback.

On Tue, May 21, 2013 at 04:17:04PM -0400, KOSAKI Motohiro wrote:
> (5/21/13 6:26 AM), Karel Zak wrote:
> > On Mon, May 20, 2013 at 09:02:43PM -0400, KOSAKI Motohiro wrote:
> >>> -	if (fl_discard)
> >>> +	if (fl_discard) {
> >>>  		flags |= SWAP_FLAG_DISCARD;
> >>> +		if (fl_discard > 1)
> >>> +			flags |= SWAP_FLAG_DISCARD_CLUSTER;
> >>
> >> This is not enough, IMHO. When running this code on old kernel, swapon() return EINVAL.
> >> At that time, we should fall back swapon(0x10000).
> > 
> >  Hmm.. currently we don't use any fallback for any swap flag (e.g.
> >  0x10000) for compatibility with old kernels. Maybe it's better to
> >  keep it simple and stupid and return an error message than introduce
> >  any super-smart semantic to hide incompatible fstab configuration.
> 
> Hm. If so, I'd propose to revert the following change. 
> 
> > .B "\-d, \-\-discard"
> >-Discard freed swap pages before they are reused, if the swap
> >-device supports the discard or trim operation.  This may improve
> >-performance on some Solid State Devices, but often it does not.
> >+Enables swap discards, if the swap device supports that, and performs
> >+a batch discard operation for the swap device at swapon time.
> 
> 
> And instead, I suggest to make --discard-on-swapon like the following.
> (better name idea is welcome) 
> 
> +--discard-on-swapon
> +Enables swap discards, if the swap device supports that, and performs
> +a batch discard operation for the swap device at swapon time.
> 
> I mean, preserving flags semantics removes the reason we need make a fallback.
> 
>

Instead of reverting and renaming --discard, what about making it accept an
optional argument, so we could use --discard (to enable all thing and keep
backward compatibility); --discard=cluster & --discard=batch (or whatever we
think it should be named). I'll try to sort this approach out if you folks think
it's worthwhile. 

-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
