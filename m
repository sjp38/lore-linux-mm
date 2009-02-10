Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 486EA6B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 09:13:14 -0500 (EST)
Received: by wa-out-1112.google.com with SMTP id k22so1310435waf.22
        for <linux-mm@kvack.org>; Tue, 10 Feb 2009 06:13:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090210135050.GB4023@csn.ul.ie>
References: <20090210162220.6FBC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20090210135050.GB4023@csn.ul.ie>
Date: Tue, 10 Feb 2009 23:13:12 +0900
Message-ID: <2f11576a0902100613g311f8387sb23f866c94bd48bf@mail.gmail.com>
Subject: Re: [PATCH] introduce for_each_populated_zone() macro
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi

>> +#define for_each_populated_zone(zone)                        \
>> +     for (zone = (first_online_pgdat())->node_zones; \
>> +          zone;                                      \
>> +          zone = next_zone(zone))                    \
>> +             if (!populated_zone(zone))              \
>> +                     ; /* do nothing */              \
>> +             else
>> +
>> +
>> +
>> +
>
> There is tabs vs whitespace damage in there.

??
I'm look at it again. but I don't found whitespace damage.

> Multiple empty lines are introduced for no apparent reason.

Will fix. thanks.

> It's not clear why you did not use if (populated_zone(zone))
> instead of an if/else.

Good question.
if we make following macro,

#define for_each_populated_zone(zone)                        \
     for (zone = (first_online_pgdat())->node_zones; \
          zone;                                      \
          zone = next_zone(zone))                    \
             if (populated_zone(zone))

and, writing following caller code.

if (always_true_assumption)
  for_each_populated_zone(){
     /* some code */
  }
else
  panic();

expand to

if (always_true_assumption)
  for()
     if (populated_zone() {
     /* some code */
  }
else
  panic();

then, memoryless node cause panic().


>
> Otherwise, I did not spot anything out of the ordinary. Nice cleanup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
