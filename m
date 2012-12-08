Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id F17BE6B0072
	for <linux-mm@kvack.org>; Sat,  8 Dec 2012 16:22:13 -0500 (EST)
Date: Sat, 08 Dec 2012 22:22:08 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <20121128145215.d23aeb1b.akpm@linux-foundation.org> <20121128235412.GW8218@suse.de> <50B77F84.1030907@leemhuis.info> <20121129170512.GI2301@cmpxchg.org> <50B8A8E7.4030108@leemhuis.info> <20121201004520.GK2301@cmpxchg.org> <50BC6314.7060106@leemhuis.info> <20121203194208.GZ24381@cmpxchg.org> <20121204214210.GB20253@cmpxchg.org> <20121205030133.GA17438@wolff.to> <20121206173742.GA27297@wolff.to> <CA+55aFzZsCUk6snrsopWQJQTXLO__G7=SjrGNyK3ePCEtZo7Sw@mail.gmail.com> <50C32D32.6040800@iskon.hr>
In-Reply-To: <50C32D32.6040800@iskon.hr>
Message-ID: <50C3AF80.8040700@iskon.hr>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: kswapd craziness in 3.7
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 08.12.2012 13:06, Zlatko Calusic wrote:
> On 06.12.2012 20:31, Linus Torvalds wrote:
>> Ok, people seem to be reporting success.
>>
>> I've applied Johannes' last patch with the new tested-by tags.
>>
>
> I've been testing this patch since it was applied, and it certainly
> fixes the kswapd craziness issue, good work Johannes!
>
> But, it's still not perfect yet, because I see that the system keeps
> lots of memory unused (free), where it previously used it all for the
> page cache (there's enough fs activity to warrant it).
>
> I'm now testing the last piece of Johannes' changes (still not in git
> tree), and can report results in 24-48 hours.
>
> Regards,

Or sooner... in short: nothing's changed!

On a 4GB RAM system, where applications use close to 2GB, kswapd likes 
to keep around 1GB free (unused), leaving only 1GB for page/buffer 
cache. If I force bigger page cache by reading a big file and thus use 
the unused 1GB of RAM, kswapd will soon (in a matter of minutes) evict 
those (or other) pages out and once again keep unused memory close to 1GB.

I guess it's not a showstopper, but it still counts as a very bad memory 
management, wasting lots of RAM.

As an additional data point, if memory pressure is slightly higher (say 
backup kicks in, keeping page cache mostly full) kswapd gets in D 
(uninterruptible sleep) state (function: congestion_wait) and load 
average goes up by 1. It recovers only when it successfully throws out 
half of page cache again.

Hope it helps.
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
