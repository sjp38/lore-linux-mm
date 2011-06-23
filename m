Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 95CE7900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 18:25:13 -0400 (EDT)
Received: by bwz17 with SMTP id 17so2798915bwz.14
        for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:25:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110623143005.GL31593@tiehlicka.suse.cz>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110616125741.c3d6a802.kamezawa.hiroyu@jp.fujitsu.com>
	<20110623134850.GK31593@tiehlicka.suse.cz>
	<BANLkTin0zMftnK2a+ex07JNdbwvEMCjXXQ@mail.gmail.com>
	<20110623143005.GL31593@tiehlicka.suse.cz>
Date: Fri, 24 Jun 2011 07:20:39 +0900
Message-ID: <BANLkTi=thFyBAKkX33ghzio392_cNkAoQg@mail.gmail.com>
Subject: Re: [PATCH 7/7] memcg: proportional fair vicitm node selection
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

2011/6/23 Michal Hocko <mhocko@suse.cz>:
> On Thu 23-06-11 23:10:11, Hiroyuki Kamezawa wrote:
>> 2011/6/23 Michal Hocko <mhocko@suse.cz>:
>> > On Thu 16-06-11 12:57:41, KAMEZAWA Hiroyuki wrote:
>> >> From 4fbd49697456c227c86f1d5b46f2cd2169bf1c5b Mon Sep 17 00:00:00 200=
1
>> >> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> >> Date: Thu, 16 Jun 2011 11:25:23 +0900
>> >> Subject: [PATCH 7/7] memcg: proportional fair node vicitm selection
>> >>
>> >> commit 889976 implements a round-robin scan of numa nodes for
>> >> LRU scanning of memcg at hitting limit.
>> >> But, round-robin is not very good.
>> >>
>> >> This patch implements a proportionally fair victim selection of nodes
>> >> rather than round-robin. The logic is fair against each node's weight=
.
>> >>
>> >> Each node's weight is calculated periodically and we build an node's
>> >> scheduling entity as
>> >>
>> >> =A0 =A0 =A0total_ticket =3D 0;
>> >> =A0 =A0 =A0for_each_node(node)
>> >> =A0 =A0 =A0 node->ticket_start =3D =A0total_ticket;
>> >> =A0 =A0 =A0 =A0 node->ticket_end =A0 =3D =A0total_ticket + this_node'=
s_weight()
>> >> =A0 =A0 =A0 =A0 total_ticket =3D node->ticket_end;
>> >>
>> >> Then, each nodes has some amounts of tickets in proportion to its own=
 weight.
>> >>
>> >> At selecting victim, a random number is selected and the node which c=
ontains
>> >> the random number in [ticket_start, ticket_end) is selected as vicitm=
.
>> >> This is a lottery scheduling algorithm.
>> >>
>> >> For quick search of victim, this patch uses bsearch().
>> >>
>> >> Test result:
>> >> =A0 on 8cpu box with 2 nodes.
>> >> =A0 limit memory to be 300MB and run httpd for 4096files/600MB workin=
g set.
>> >> =A0 do (normalized) random access by apache-bench and see scan_stat.
>> >> =A0 The test makes 40960 request. and see scan_stat.
>> >> =A0 (Because a httpd thread just use 10% cpu, the number of threads w=
ill
>> >> =A0 =A0not be balanced between nodes. Then, file caches will not be b=
alanced
>> >> =A0 =A0between nodes.)
>> >
>> > Have you also tried to test with balanced nodes? I mean, is there any
>> > measurable overhead?
>> >
>>
>> Not enough yet. I checked OOM trouble this week :).
>>
>> I may need to make another fake_numa setup + cpuset
>> to measurements.
>
> What if you just use NUMA rotor for page cache?
>

Ok, I'll do try in the next week. Thank you for suggestion.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
