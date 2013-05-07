Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 4D3EC6B00D8
	for <linux-mm@kvack.org>; Tue,  7 May 2013 11:55:06 -0400 (EDT)
Received: by mail-bk0-f47.google.com with SMTP id jg9so380495bkc.20
        for <linux-mm@kvack.org>; Tue, 07 May 2013 08:55:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130507154814.GG9497@dhcp22.suse.cz>
References: <1367768681-4451-1-git-send-email-handai.szj@taobao.com>
	<20130507141208.GD9497@dhcp22.suse.cz>
	<51891816.806@oracle.com>
	<20130507151508.GF9497@dhcp22.suse.cz>
	<51891DF6.6060007@oracle.com>
	<20130507154814.GG9497@dhcp22.suse.cz>
Date: Tue, 7 May 2013 23:55:04 +0800
Message-ID: <CAFj3OHVWQeB8D-6mVFBb+P4a7nyfLbBCx5ChtVmKZoL7M2_xoQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] memcg: replace memparse to avoid input overflow
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Jeff Liu <jeff.liu@oracle.com>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Sha Zhengju <handai.szj@taobao.com>

On Tue, May 7, 2013 at 11:48 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Tue 07-05-13 23:29:58, Jeff Liu wrote:
>> On 05/07/2013 11:15 PM, Michal Hocko wrote:
>> > On Tue 07-05-13 23:04:54, Jeff Liu wrote:
>> >> On 05/07/2013 10:12 PM, Michal Hocko wrote:
>> >>> On Sun 05-05-13 23:44:41, Sha Zhengju wrote:
>> >>>> memparse() doesn't check if overflow has happens, and it even has no
>> >>>> args to inform user that the unexpected situation has occurred. Besides,
>> >>>> some of its callers make a little artful use of the current implementation
>> >>>> and it also seems to involve too much if changing memparse() interface.
>> >>>>
>> >>>> This patch rewrites memcg's internal res_counter_memparse_write_strategy().
>> >>>> It doesn't use memparse() any more and replaces simple_strtoull() with
>> >>>> kstrtoull() to avoid input overflow.
>> >>>
>> >>> I do not like this to be honest. I do not think we should be really
>> >>> worried about overflows here. Or where this turned out to be a real
>> >>> issue?
>> >> Yes. e.g.
>> >> Without this validation, user could specify a big value larger than ULLONG_MAX
>> >> which would result in 0 because of an overflow.  Even worse, all the processes
>> >> belonging to this group will be killed by OOM-Killer in this situation.
>> >
>> > I would consider this to be a configuration problem.
>> It mostly should be a problem of configuration.
>> >
>> >>> The new implementation is inherently slower without a good
>> >>> reason.
>> >> In talking about this, I also concerned for the overhead as per an offline
>> >> discussion with Sha when she wrote this fix.  However, can we consider it to be
>> >> a tradeoff as this helper is not being used in any hot path?
>> >
>> > what is the positive part of the trade off? Fixing a potential overflow
>> > when somebody sets a limit to an unreasonable value?
>> I suppose it to be a defense for unreasonable value because this issue
>> is found on a production environment for an incorrect manipulation, but
>> it's up to you.
>
> I _really_ do not want to punish everybody just because of somthing that
> is a configuration issue.

Okay, Let's lay it aside for the moment.  Thank you!

>
>>
>> Thanks,
>> -Jeff
> --
> Michal Hocko
> SUSE Labs
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--
Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
