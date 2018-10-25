Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C5A126B0007
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 01:31:43 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c28-v6so5717680pfe.4
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 22:31:43 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id j16-v6si6699321pgg.350.2018.10.24.22.31.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 22:31:42 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Thu, 25 Oct 2018 11:01:41 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH] mm: convert totalram_pages, totalhigh_pages and
 managed_pages to atomic.
In-Reply-To: <alpine.DEB.2.21.1810230711220.2343@hadrien>
References: <1540229092-25207-1-git-send-email-arunks@codeaurora.org>
 <20181022181122.GK18839@dhcp22.suse.cz>
 <CABOM9Zpq41Ox8wQvsNjgfCtwuqh6CnyeW1B09DWa1TQN+JKf0w@mail.gmail.com>
 <20181023053359.GL18839@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810230711220.2343@hadrien>
Message-ID: <9bd14fb3c0ce8ca9a33c33ce81e66037@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Cc: Michal Hocko <mhocko@kernel.org>, Arun Sudhilal <getarunks@gmail.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>

On 2018-10-23 11:43, Julia Lawall wrote:
> On Tue, 23 Oct 2018, Michal Hocko wrote:
> 
>> [Trimmed CC list + Julia - there is indeed no need to CC everybody 
>> maintain a
>> file you are updating for the change like this]
>> 
>> On Tue 23-10-18 10:16:51, Arun Sudhilal wrote:
>> > On Mon, Oct 22, 2018 at 11:41 PM Michal Hocko <mhocko@kernel.org> wrote:
>> > >
>> > > On Mon 22-10-18 22:53:22, Arun KS wrote:
>> > > > Remove managed_page_count_lock spinlock and instead use atomic
>> > > > variables.
>> > >
>> >
>> > Hello Michal,
>> > > I assume this has been auto-generated. If yes, it would be better to
>> > > mention the script so that people can review it and regenerate for
>> > > comparision. Such a large change is hard to review manually.
>> >
>> > Changes were made partially with script.  For totalram_pages and
>> > totalhigh_pages,
>> >
>> > find dir -type f -exec sed -i
>> > 's/totalram_pages/atomic_long_read(\&totalram_pages)/g' {} \;
>> > find dir -type f -exec sed -i
>> > 's/totalhigh_pages/atomic_long_read(\&totalhigh_pages)/g' {} \;
>> >
>> > For managed_pages it was mostly manual edits after using,
>> > find mm/ -type f -exec sed -i
>> > 's/zone->managed_pages/atomic_long_read(\&zone->managed_pages)/g' {}
>> > \;
>> 
>> I guess we should be able to use coccinelle for this kind of change 
>> and
>> reduce the amount of manual intervention to absolute minimum.
> 
> Coccinelle looks like it would be desirable, especially in case the 
> word
> zone is not always used.
> 
> Arun, please feel free to contact me if you want to try it and need 
> help.
Hello Julia,

I was able to come up .cocci for replacing managed_pages,

@@
struct zone *z;
@@
(
z->managed_pages = ...
|
- z->managed_pages
+ atomic_long_read(&z->managed_pages)
)

@@
struct zone *z;
expression e1;
@@
- z->managed_pages = e1
+ atomic_long_set(&z->managed_pages, e1)

@@
expression e,e1;
@@
- e->managed_pages += e1
+ atomic_long_add(e1, &e->managed_pages)

@@
expression z;
@@
- z.managed_pages
+ atomic_long_read(&z.managed_pages)

But I m not able to use same method for unsigned long 
variables(totalram_pages)

@@
unsigned long totalram_pages;
@@
(
totalram_pages = ...
|
-totalram_pages
+atomic_long_read(&totalram_pages)
)

This throws error,

spatch test1.cocci mm/page_alloc.c
init_defs_builtins: /usr/lib/coccinelle/standard.h
HANDLING: mm/page_alloc.c

previous modification:
MINUS
   >>> atomic_long_read(&rule starting on line 1:totalram_pages)

According to environment 1:
    rule starting on line 1.totalram_pages -> page_idx ^ (1 <<
order)

current modification:
MINUS
   >>> atomic_long_read(&rule starting on line 1:totalram_pages)

According to environment 1:
    rule starting on line 1.totalram_pages -> page_idx

Fatal error: exception Failure("rule starting on line 1: already tagged 
token:
C code context
File "mm/internal.h", line 175, column 8,  charpos = 5368
     around = 'page_idx', whole content =        return page_idx ^ (1 << 
order);")

Regards,
Arun


> 
> julia
