Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C1B2D900138
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 22:18:38 -0400 (EDT)
Received: by iyn15 with SMTP id 15so3334154iyn.34
        for <linux-mm@kvack.org>; Wed, 17 Aug 2011 19:18:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201108111938.25836.vda.linux@googlemail.com>
References: <1312872786.70934.YahooMailNeo@web111712.mail.gq1.yahoo.com>
 <CAK1hOcN7q=F=UV=aCAsVOYO=Ex34X0tbwLHv9BkYkA=ik7G13w@mail.gmail.com>
 <1313075625.50520.YahooMailNeo@web111715.mail.gq1.yahoo.com> <201108111938.25836.vda.linux@googlemail.com>
From: Pavel Ivanov <paivanof@gmail.com>
Date: Wed, 17 Aug 2011 22:18:06 -0400
Message-ID: <CAG1a4rsO7JDqmYiwyxPrAHdLNbJt+wqymSzU9i1dv5w5C2OFog@mail.gmail.com>
Subject: Re: running of out memory => kernel crash
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Denys Vlasenko <vda.linux@googlemail.com>
Cc: Mahmood Naderan <nt_mahmood@yahoo.com>, David Rientjes <rientjes@google.com>, Randy Dunlap <rdunlap@xenotime.net>, "\"linux-kernel@vger.kernel.org\"" <linux-kernel@vger.kernel.org>, "\"linux-mm@kvack.org\"" <linux-mm@kvack.org>

Denys,

>> Why "killing" does not appear here? Why it try to "find some
>> recently used page"?
>
> Because killing is the last resort. As long as kernel can free
> a page by dropping an unmodified file-backed page, it will do that.
> When there is nothing more to drop, and still more free pages
> are needed, _then_ kernel will start oom killing.

I have a little concern about this explanation of yours. Suppose we
have some amount of more or less actively executing processes in the
system. Suppose they started to use lots of resident memory. Amount of
memory they use is less than total available physical memory but when
we add total size of code for those processes it would be several
pages more than total size of physical memory. As I understood from
your explanation in such situation one process will execute its time
slice, kernel will switch to other one, find that its code was pushed
out of RAM, read it from disk, execute its time slice, switch to next
process, read its code from disk, execute and so on. So system will be
virtually unusable because of constantly reading from disk just to
execute next small piece of code. But oom will never be firing in such
situation. Is my understanding correct? Shouldn't it be considered as
an unwanted behavior?


Pavel


On Thu, Aug 11, 2011 at 1:38 PM, Denys Vlasenko
<vda.linux@googlemail.com> wrote:
> On Thursday 11 August 2011 17:13, Mahmood Naderan wrote:
>> >What it can possibly do if there is no swap and therefore it
>>
>> >can't free memory by writing out RAM pages to swap?
>>
>>
>> >the disk activity comes from constant paging in (reading)
>> >of pages which contain code of running binaries.
>>
>> Why the disk activity does not appear in the first scenario?
>
> Because there is nowhere to write dirty pages in order to free
> some RAM (since you have no swap) and reading in more stuff
> from disk can't possibly help with freeing RAM.
>
> (What kernel does in order to free RAM is it drops unmodified
> file-backed pages, and doing _that_ doesn't require disk I/O).
>
> Thus, no reading and no writing is necessary/possible.
>
>
>> >Thus the only option is to find some not recently used page
>> > with read-only, file-backed content (usually some binary's
>>
>> >text page, but can be any read-only file mapping) and reuse it.
>> Why "killing" does not appear here? Why it try to "find some
>>
>> recently used page"?
>
> Because killing is the last resort. As long as kernel can free
> a page by dropping an unmodified file-backed page, it will do that.
> When there is nothing more to drop, and still more free pages
> are needed, _then_ kernel will start oom killing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
