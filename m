Received: by wa-out-1112.google.com with SMTP id j37so1368485waf.22
        for <linux-mm@kvack.org>; Sun, 16 Nov 2008 22:39:20 -0800 (PST)
Message-ID: <2f11576a0811162239w58555c6dq8a61ec184b22bd52@mail.gmail.com>
Date: Mon, 17 Nov 2008 15:39:20 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: evict streaming IO cache first
In-Reply-To: <20081117153012.51ece88f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20081115210039.537f59f5.akpm@linux-foundation.org>
	 <alpine.LFD.2.00.0811161013270.3468@nehalem.linux-foundation.org>
	 <49208E9A.5080801@redhat.com>
	 <20081116204720.1b8cbe18.akpm@linux-foundation.org>
	 <20081117153012.51ece88f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Gene Heskett <gene.heskett@gmail.com>
List-ID: <linux-mm.kvack.org>

2008/11/17 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
> On Sun, 16 Nov 2008 20:47:20 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> On Sun, 16 Nov 2008 16:20:26 -0500 Rik van Riel <riel@redhat.com> wrote:
>> Anyway, we need to do something.
>>
>> Shouldn't get_scan_ratio() be handling this case already?
>>
> Hmm, could I make a question ?
>
> I think
>
>  - recent_rolated[LRU_FILE] is incremented when file cache is moved from
>    ACTIVE_FILE to INACTIVE_FILE.
>  - recent_scanned[LRU_FILE] is sum of scanning numbers on INACTIVE/ACTIVE list
>    of file.
>  - file caches are added to INACITVE_FILE, at first.
>  - get_scan_ratio() calculates %file to be
>
>                         file        recent rotated.
>   %file = IO_cost * ------------ / -------------
>                      anon + file    recent scanned.

rewote by div to mul changing.


                        file               recent scanned.
  %file = IO_cost * ------------ * -------------
                     anon + file       recent rotated.


> But when "files are used by streaming or some touch once application",
> there is no rotation because they are in INACTIVE FILE at first add_to_lru().
> But recent_rotated will not increase while recent_scanned goes bigger and bigger.

Yup.

> Then %file goes to 0 rapidly.

I think reverse.

The problem is, when streaming access started right after, recent
scanned isn't so much.
then %file don't reach 100%.

then, few anon pages swaped out althouth memory pressure isn't so heavy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
