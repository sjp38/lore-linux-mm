Received: by an-out-0708.google.com with SMTP id d17so707576and.105
        for <linux-mm@kvack.org>; Tue, 20 May 2008 07:56:38 -0700 (PDT)
Message-ID: <8347f3fb0805200756q294b08b7jff3dfbb8345d004b@mail.gmail.com>
Date: Tue, 20 May 2008 10:56:38 -0400
From: "Randy Johnson" <theraptor2005@gmail.com>
Subject: Re: 2.6.25.1: Kernel BUG at mm/rmap.c:669, General Protection Faults, and generic hard locks
In-Reply-To: <Pine.LNX.4.64.0805161110210.565@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <8347f3fb0805111721m57ba99e4l21df02d38ca3f41f@mail.gmail.com>
	 <8347f3fb0805121555k266fab9fvf9d006ab2a89dd7a@mail.gmail.com>
	 <Pine.LNX.4.64.0805161110210.565@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, May 16, 2008 at 7:09 AM, Hugh Dickins <hugh@veritas.com> wrote:
> On Mon, 12 May 2008, Randy Johnson wrote:
>> Sent this to linux-kernel, then realized I probably should have sent
>> this here as well...
>>
>> Hi,
>>
>> Recently moved from 2.6.22 up to 2.6.25.1 to solve some AHCI issues.
>> Following this update, Matlab has caused numerous hard lockups. I've
>> gotten lucky twice and been able to remote in and get the logs, which
>> follow below. System is an AM2 with 6G ram installed, but booted with
>> mem=3200M to circumvent some IOMMU issues. It is possible to
>
> I expect your "mem=3200M" is just fine, I'm fond of "mem=" myself;
> but be aware that you can get into trouble with it, and I've heard
> "memmap=" recommended instead.  If you're unfamiliar with that,
> try Documentation/kernel-parameters.txt or googling.
>
>> eventually replicate the issue, but not with a specific sequence of
>> activities that I've found. General activity from Matlab when it
>> occurs is heavy disk IO (reading, no writting), and large memory
>> consumption. Latest version of memtest86+ was run overnight and shows
>> no issues.
>
> memtest86+ overnight was certainly the right thing to try;
> but I'm not convinced by its success.  Maybe there's a pattern
> in Matlab which is tickling a bad RAM issue more effectively
> than memtest does (sometimes gcc hits problems which memtest
> hasn't shown).  And since (sadly!) you have plenty of memory
> to spare, it'd be well worth switching boards around: your
> lowest bank does look suspect (and I'm guessing 2.6.25.1 just
> places things differently from 2.6.22, some important data now
> being placed on bad RAM where something unused went before).

I did manage to steal another complete set of RAM and swapped it in,
with no change. This still doesn't rule out potential issues with the
MB (slots or controller); I've got a spare board coming in in the next
week.

In the mean time, I've been busy bisecting this one down.
Unfortunately, it takes a good hour or two of heavy load to trigger
sometimes, and I've got a good 15000 or so commits to get through, so
it could still be a while. I haven't been keeping any traces from
these, even if I could get them (which typically I can't). Would they
still be useful even if they're from random commits?

> I could perfectly well be wrong about all that: maybe you do have
> a kernel bug corrupting your memory; but I've no idea where if so.
>
>>
>> Any thoughts?
>>
>> -Randy Johnson
>>
>>
>> log #1
>>
>> Eeek! page_mapcount(page) went negative! (-1946157056)
>
> That's the most interesting line of it: page_mapcount(page) isn't
> off-by one or something like that, instead its high byte has been
> corrupted at some point from 0x00 to 0x8c.
>
> (Unfortunately, what with all the printk'ing that's gone on, I'm not
> at all confident whether or where the address of the page in question
> is in the registers or stack displayed: the messages suit tracking
> a relevant kernel bug rather than a random corruption.)
>
>>
>> And log #2
>>
>> general protection fault: 0000 [1] SMP
>> CPU 1
>> Modules linked in: af_packet aic7xxx fan button thermal processor unix
>> Pid: 6232, comm: MATLAB Not tainted 2.6.25.1 #1
>> RIP: 0010:[<ffffffff802652e3>]  [<ffffffff802652e3>]
>> get_page_from_freelist+0x303/0x670
>> RSP: 0000:ffff8100b2421d78  EFLAGS: 00010002
>> RAX: ffff8100bf64bb10 RBX: ffff8100bf64bb10 RCX: ffffe200029538d8
>> RDX: 7fffe200004bee10 RSI: 0000000000000000 RDI: 000000000000001d
>       ^
> There it's doing the list_del(&page->lru) in buffered_rmqueue(),
> and hitting a corrupted prev pointer: the top bit of the address has
> been cleared, causing that and subsequent general protection faults
> (same list pointer RCX and prev contents RDX each time).
>
> But I'm afraid that tells me nothing about the cause of these
> corruptions.  If you've gathered more crash logs during the week,
> please do post the logs or send them to me privately, I'll try
> to decipher what I can - but that may not help you much.
>
> Hugh
>


-Randy Johnson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
