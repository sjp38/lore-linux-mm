Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 987A16B005A
	for <linux-mm@kvack.org>; Sat, 29 Dec 2012 07:11:32 -0500 (EST)
Date: Sat, 29 Dec 2012 13:11:28 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <50D24AF3.1050809@iskon.hr> <50D24CD9.8070507@iskon.hr> <CAJd=RBCQN1GxOUCwGPXL27d_q8hv50uHK5LhDnsv7mdv_2Usaw@mail.gmail.com> <50DC6C6F.6050703@iskon.hr> <CAJd=RBB0bwyjoMc5yt5SfgxCt3JcLUo8Fiz1r3oQ0RRhE1i59w@mail.gmail.com>
In-Reply-To: <CAJd=RBB0bwyjoMc5yt5SfgxCt3JcLUo8Fiz1r3oQ0RRhE1i59w@mail.gmail.com>
Message-ID: <50DEDDF0.8090405@iskon.hr>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] mm: do not sleep in balance_pgdat if there's no i/o congestion
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 29.12.2012 08:25, Hillf Danton wrote:
> On Thu, Dec 27, 2012 at 11:42 PM, Zlatko Calusic
> <zlatko.calusic@iskon.hr> wrote:
>> On 21.12.2012 12:51, Hillf Danton wrote:
>>>
>>> On Thu, Dec 20, 2012 at 7:25 AM, Zlatko Calusic <zlatko.calusic@iskon.hr>
>>> wrote:
>>>>
>>>>    static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>>>>                                                           int
>>>> *classzone_idx)
>>>>    {
>>>> -       int all_zones_ok;
>>>> +       struct zone *unbalanced_zone;
>>>
>>>
>>> nit: less hunks if not erase that mark
>>>
>>> Hillf
>>
>>
>> This one left unanswered and forgotten because I didn't understand what you
>> meant. Could you elaborate?
>>
> Sure, the patch looks simpler(and nicer) if we dont
> erase all_zones_ok.
>

Ah, yes. I gave it a good thought. But, when I introduced 
unbalanced_zone it just didn't make much sense to me to have two 
variables with very similar meaning. If I decided to keep all_zones_ok, 
it would be either:

all_zones_ok = true
unbalanced_zone = NULL
(meaning: if no zone in unbalanced, then all zones must be ok)

or

all_zones_ok = false
unbalanced_zone = struct zone *
(meaning: if there's an unbalanced zone, then certainly not all zones 
are ok)

So I decided to use only unbalanced_zone (because I had to!), and remove 
all_zones_ok to avoid redundancy. I hope it makes sense.

If you check my latest (and still queued) optimization (mm: avoid 
calling pgdat_balanced() needlessly), there again popped up a need for a 
boolean, but I called it pgdat_is_balanced this time, just to match the 
name of two other functions. It could've also been called all_zones_ok 
if you prefer the name? Of course, I have no strong feelings about the 
name, both are OK, so if you want me to redo the patch, just say.

Generally speaking, while I always attempt to make a smaller patch (less 
hunks and less changes = easier to review), before that I'll always try 
to make the code that results from the commit cleaner, simpler, more 
readable.

For example, I'll always check that I don't mess with whitespace 
needlessly, unless I think it's actually desirable, here's just one example:

"mm: avoid calling pgdat_balanced() needlessly" changes

---
         } while (--sc.priority >= 0);
out:

         if (!pgdat_balanced(pgdat, order, *classzone_idx)) {
---

to

---
         } while (--sc.priority >= 0);

out:
         if (!pgdat_is_balanced) {
---

because I find the latter more correct place for the label "out".

Thanks for the comment.
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
