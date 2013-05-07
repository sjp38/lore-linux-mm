Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 1305A6B00DB
	for <linux-mm@kvack.org>; Tue,  7 May 2013 11:48:18 -0400 (EDT)
Date: Tue, 7 May 2013 17:48:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/3] memcg: replace memparse to avoid input overflow
Message-ID: <20130507154814.GG9497@dhcp22.suse.cz>
References: <1367768681-4451-1-git-send-email-handai.szj@taobao.com>
 <20130507141208.GD9497@dhcp22.suse.cz>
 <51891816.806@oracle.com>
 <20130507151508.GF9497@dhcp22.suse.cz>
 <51891DF6.6060007@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51891DF6.6060007@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: Sha Zhengju <handai.szj@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, nishimura@mxp.nes.nec.co.jp, akpm@linux-foundation.org, Sha Zhengju <handai.szj@taobao.com>

On Tue 07-05-13 23:29:58, Jeff Liu wrote:
> On 05/07/2013 11:15 PM, Michal Hocko wrote:
> > On Tue 07-05-13 23:04:54, Jeff Liu wrote:
> >> On 05/07/2013 10:12 PM, Michal Hocko wrote:
> >>> On Sun 05-05-13 23:44:41, Sha Zhengju wrote:
> >>>> memparse() doesn't check if overflow has happens, and it even has no
> >>>> args to inform user that the unexpected situation has occurred. Besides,
> >>>> some of its callers make a little artful use of the current implementation
> >>>> and it also seems to involve too much if changing memparse() interface.
> >>>>
> >>>> This patch rewrites memcg's internal res_counter_memparse_write_strategy().
> >>>> It doesn't use memparse() any more and replaces simple_strtoull() with
> >>>> kstrtoull() to avoid input overflow.
> >>>
> >>> I do not like this to be honest. I do not think we should be really
> >>> worried about overflows here. Or where this turned out to be a real
> >>> issue? 
> >> Yes. e.g.
> >> Without this validation, user could specify a big value larger than ULLONG_MAX
> >> which would result in 0 because of an overflow.  Even worse, all the processes
> >> belonging to this group will be killed by OOM-Killer in this situation.
> > 
> > I would consider this to be a configuration problem.
> It mostly should be a problem of configuration.
> >  
> >>> The new implementation is inherently slower without a good
> >>> reason.
> >> In talking about this, I also concerned for the overhead as per an offline
> >> discussion with Sha when she wrote this fix.  However, can we consider it to be
> >> a tradeoff as this helper is not being used in any hot path?
> > 
> > what is the positive part of the trade off? Fixing a potential overflow
> > when somebody sets a limit to an unreasonable value?
> I suppose it to be a defense for unreasonable value because this issue
> is found on a production environment for an incorrect manipulation, but
> it's up to you.

I _really_ do not want to punish everybody just because of somthing that
is a configuration issue.

> 
> Thanks,
> -Jeff
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
