Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 54EB66B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 03:51:48 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 204so36557202pfx.1
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 00:51:48 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id w190si8622619pfb.30.2017.01.12.00.51.46
        for <linux-mm@kvack.org>;
        Thu, 12 Jan 2017 00:51:47 -0800 (PST)
Date: Thu, 12 Jan 2017 17:48:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: + mm-vmscan-add-mm_vmscan_inactive_list_is_low-tracepoint.patch
 added to -mm tree
Message-ID: <20170112084813.GA24030@bbox>
References: <586edadc.figmHAGrTxvM7Wei%akpm@linux-foundation.org>
 <20170110235250.GA7130@bbox>
 <20170111155239.GD16365@dhcp22.suse.cz>
 <20170112051247.GA8387@bbox>
 <20170112081554.GB2264@dhcp22.suse.cz>
MIME-Version: 1.0
In-Reply-To: <20170112081554.GB2264@dhcp22.suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, hillf.zj@alibaba-inc.com, mgorman@suse.de, vbabka@suse.cz, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Thu, Jan 12, 2017 at 09:15:54AM +0100, Michal Hocko wrote:
> On Thu 12-01-17 14:12:47, Minchan Kim wrote:
> > Hello,
> > 
> > On Wed, Jan 11, 2017 at 04:52:39PM +0100, Michal Hocko wrote:
> > > On Wed 11-01-17 08:52:50, Minchan Kim wrote:
> > > [...]
> > > > > @@ -2055,8 +2055,8 @@ static bool inactive_list_is_low(struct
> > > > >  	if (!file && !total_swap_pages)
> > > > >  		return false;
> > > > >  
> > > > > -	inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
> > > > > -	active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
> > > > > +	total_inactive = inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
> > > > > +	total_active = active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
> > > > >  
> > > > 
> > > > the decision of deactivating is based on eligible zone's LRU size,
> > > > not whole zone so why should we need to get a trace of all zones's LRU?
> > > 
> > > Strictly speaking, the total_ counters are not necessary for making the
> > > decision. I found reporting those numbers useful regardless because this
> > > will give us also an information how large is the eligible portion of
> > > the LRU list. We do not have any other tracepoint which would report
> > > that.
> > 
> > The patch doesn't say anything why it's useful. Could you tell why it's
> > useful and inactive_list_is_low should be right place?
> > 
> > Don't get me wrong, please. I don't want to bother you.
> > I really don't want to add random stuff although it's tracepoint for
> > debugging.
> 
> This doesn't sounds random to me. We simply do not have a full picture
> on 32b systems without this information. Especially when memcgs are
> involved and global numbers spread over different LRUs.

Could you elaborate it?

"
Currently we have tracepoints for both active and inactive LRU lists
reclaim but we do not have any which would tell us why we we decided to
age the active list.  Without that it is quite hard to diagnose
active/inactive lists balancing.  Add mm_vmscan_inactive_list_is_low
tracepoint to tell us this information.
"

Your description says "why we decided to age the active list".
So, what's needed?

>  
> > > [...]
> > > > > @@ -2223,7 +2228,7 @@ static void get_scan_count(struct lruvec
> > > > >  	 * lruvec even if it has plenty of old anonymous pages unless the
> > > > >  	 * system is under heavy pressure.
> > > > >  	 */
> > > > > -	if (!inactive_list_is_low(lruvec, true, sc) &&
> > > > > +	if (!inactive_list_is_low(lruvec, true, sc, false) &&
> > > > 
> > > > Hmm, I was curious why you added trace boolean arguement and found it here.
> > > > Yes, here is not related to deactivation directly but couldn't we help to
> > > > trace it unconditionally?
> > > 
> > > I've had it like that when I was debugging the mentioned bug and found
> > > it a bit disturbing. It generated more output than I would like and it
> > > wasn't really clear from which code path  this has been called from.
> > 
> > Indeed.
> > 
> > Personally, I want to move inactive_list_is_low in shrink_active_list
> > and shrink_active_list calls inactive_list_is_low(...., true),
> > unconditionally so that it can make code simple/clear but cannot remove
> > trace boolean variable , which what I want. So, it's okay if you love
> > your version.
> 
> I am not sure I am following. Why is the additional parameter a problem?

Well, to me, it's not a elegance. Is it? If we need such boolean variable
to control show the trace, it means it's not a good place or think
refactoring.

> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
