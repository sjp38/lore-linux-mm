Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 071E56B0031
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 04:32:59 -0400 (EDT)
Message-ID: <51B04968.7080105@parallels.com>
Date: Thu, 6 Jun 2013 12:33:44 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v10 35/35] memcg: reap dead memcgs upon global memory
 pressure.
References: <1370287804-3481-1-git-send-email-glommer@openvz.org> <1370287804-3481-36-git-send-email-glommer@openvz.org> <20130605160902.2e656a43aa7c5a51a574ea48@linux-foundation.org>
In-Reply-To: <20130605160902.2e656a43aa7c5a51a574ea48@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel
 Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes
 Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>

On 06/06/2013 03:09 AM, Andrew Morton wrote:
> On Mon,  3 Jun 2013 23:30:04 +0400 Glauber Costa <glommer@openvz.org> wrote:
> 
>> When we delete kmem-enabled memcgs, they can still be zombieing
>> around for a while. The reason is that the objects may still be alive,
>> and we won't be able to delete them at destruction time.
>>
>> The only entry point for that, though, are the shrinkers. The
>> shrinker interface, however, is not exactly tailored to our needs. It
>> could be a little bit better by using the API Dave Chinner proposed, but
>> it is still not ideal since we aren't really a count-and-scan event, but
>> more a one-off flush-all-you-can event that would have to abuse that
>> somehow.
> 
> This patch is significantly dependent on
> http://ozlabs.org/~akpm/mmots/broken-out/memcg-debugging-facility-to-access-dangling-memcgs.patch,
> which was designated "mm only debug patch" when I merged it six months
> ago.
> 
> We can go ahead and merge
> memcg-debugging-facility-to-access-dangling-memcgs.patch upstream I
> guess, but we shouldn't do that just because it makes the
> patch-wrangling a bit easier!
> 
> Is memcg-debugging-facility-to-access-dangling-memcgs.patch worth merging in
> its own right?  If so, what changed since our earlier decision?
> 

I was under the impression that it *was* merged, even though it
shouldn't - it was showing up on -next, so I could be wrong. I am
basically using part of the infrastructure for this patch, but the rest
can go away.

If the patch isn't really merged and I was just confused (can happen),
what I would prefer to do is what I have done originally: I will append
part of that in this patch (the part the adds memcgs to the dangling
list), and leave the file part in a separate patch. I will then resend
you that patch as a debug-only patch.

To do that, it would be mostly helpful if you could remove that for your
tree temporarily.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
