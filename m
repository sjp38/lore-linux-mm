Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id EF3266B13F0
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 07:26:54 -0500 (EST)
Date: Thu, 2 Feb 2012 14:27:47 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] memcg: make threshold index in the right position
Message-ID: <20120202122747.GA12575@shutemov.name>
References: <1328175919-11209-1-git-send-email-handai.szj@taobao.com>
 <20120202101410.GA12291@shutemov.name>
 <4F2A6B5F.3090303@gmail.com>
 <4F2A6EBC.5090207@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F2A6EBC.5090207@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu, Feb 02, 2012 at 07:08:44PM +0800, Sha Zhengju wrote:
> On 02/02/2012 06:54 PM, Sha Zhengju wrote:
> >On 02/02/2012 06:14 PM, Kirill A. Shutemov wrote:
> >>On Thu, Feb 02, 2012 at 05:45:19PM +0800, Sha Zhengju wrote:
> >>>From: Sha Zhengju<handai.szj@taobao.com>
> >>>
> >>>Index current_threshold may point to threshold that just equal to
> >>>usage after __mem_cgroup_threshold is triggerd.
> >>I don't see it. Could you describe conditions?
> >>
> >It is because of the following code path in __mem_cgroup_threshold:
> >{
> >    ...
> >        i = t->current_threshold;
> >
> >        for (; i >= 0 && unlikely(t->entries[i].threshold > usage); i--)
> >                eventfd_signal(t->entries[i].eventfd, 1);
> >        i++;
> >
> >        for (; i < t->size && unlikely(t->entries[i].threshold <=
> >usage); i++)
> >                eventfd_signal(t->entries[i].eventfd, 1);
> >
> >        t->current_threshold = i - 1;
> >    ...
> >}
> >
> >For example:
> >now:
> >    threshold array:  3  5  7  9   (usage = 6)
> >                                   ^
> >                                index
> >
> >next turn:
> >    threshold array:  3  5  7  9   (usage = 7)
> >                                       ^
> >                                    index
> >
> >after registering a new event(threshold = 10):
> >    threshold array:  3  5  7  9  10 (usage = 7)
> >                                   ^
> >                                index
> Err.. Sorry for showing inaccurate index position... (may because of
> the mail format)
> 
> now:
>     threshold array:  3  [5]  7  9   (usage = 6, index = 5)
> 
> next turn:
>     threshold array:  3  5  [7]  9   (usage = 7, index = 7)
> 
> after registering a new event(threshold = 10):
>     threshold array:  3  [5]  7  9  10 (usage = 7, index = 5)

Good catch! Thank you.

Reviewed-by: Kirill A. Shutemov <kirill@shutemov.name>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
