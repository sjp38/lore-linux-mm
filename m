Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 307B76B006E
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 18:22:10 -0500 (EST)
Received: by mail-lb0-f181.google.com with SMTP id u10so5812458lbd.12
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 15:22:09 -0800 (PST)
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com. [209.85.217.180])
        by mx.google.com with ESMTPS id r3si16525793lbo.9.2015.01.20.15.22.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 15:22:08 -0800 (PST)
Received: by mail-lb0-f180.google.com with SMTP id b6so10815048lbj.11
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 15:22:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CANP1eJG36DYG8xezydcuWAw6d-Khz9ULr9WMuJ6kfpPzJEoOXw@mail.gmail.com>
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
	<20150115223157.GB25884@quack.suse.cz>
	<CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>
	<20150116165506.GA10856@samba2>
	<CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com>
	<20150119071218.GA9747@jeremy-HP>
	<1421652849.2080.20.camel@HansenPartnership.com>
	<CANP1eJHYUprjvO1o6wfd197LM=Bmhi55YfdGQkPT0DKRn3=q6A@mail.gmail.com>
	<54BD234F.3060203@kernel.dk>
	<54BEAD82.3070501@kernel.dk>
	<CANP1eJG36DYG8xezydcuWAw6d-Khz9ULr9WMuJ6kfpPzJEoOXw@mail.gmail.com>
Date: Tue, 20 Jan 2015 18:22:08 -0500
Message-ID: <CANP1eJHqhYZ9_yf16LKaUMvHEJN7eERpKSBYVrtQhr8ZkGVVsQ@mail.gmail.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace apps
From: Milosz Tanski <milosz@adfin.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Jeremy Allison <jra@samba.org>, Volker Lendecke <Volker.Lendecke@sernet.de>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org

Side note Jens.

Can you add a configure flag to disable use of SHM (like for ESX)? It
took me a while to figure out the proper define to manually stick in
the configure.

The motivation for this is using rr (mozila's replay debugger) to
debug fio. rr doesn't support SHM. http://rr-project.org/ gdb's
reversible debugging is too painfully slow.

Thanks,
- Milosz

On Tue, Jan 20, 2015 at 6:07 PM, Milosz Tanski <milosz@adfin.com> wrote:
> Great, I'll pull into my branch. I'm already using FIO with the cifs
> engine to test and help me debug preadv2 changes to smbd and it works
> without issues for me today. I'm going to work on the async cifs
> engine but that will take longer because I need to expose build the
> async SMB2 support into libsmbclient. I'm going to leave that work
> till after I get further with preadv2 in samba (hopefully this week).
>
> I think the biggest issue with the changes is the configure part of my
> changes (as seen here:
> http://git.kernel.dk/?p=fio.git;a=blobdiff;f=configure;h=d4502095250cdf5187b24276c327b727d3d87288;hp=33d1327ebbba5b70a001e422bb5ad9b24d7c7b49;hb=7fd35359259b409ed023b924cb2758e9efb9950c;hpb=5fb4b36674b194ae6c6756314dc0c665fcaea06d
> ).
>
> The way samba packages the client libraries beyond just smbclient-raw
> requiring me to pull in other libraries and then mess with rpath to
> guess the distro location is far for ideal. I haven't reported it yet
> mostly because I was interested it making progress and making it work.
> Ideally samba folks would fix the pkgconfig file for smbclient-raw to
> set right LDPATH (including all the depending libraries and rpath) so
> that stuff is not needed.
>
> Additionally, there's a few things not exported in the header files
> (but used) like:
> http://git.kernel.dk/?p=fio.git;a=blob;f=engines/cifs.c;h=67c23fac0c70cfc75932c758f44dd377fc3f2608;hb=7fd35359259b409ed023b924cb2758e9efb9950c#l16
> . It looks like lpcfg_resolve_context() is the only way to create a
> struct resolve_context which is used in the cliraw hreads, but
> lpcfg_resolve_context() is not exported via the header files.
>
> Some of this might be not using the library correctly... there really
> wasn't any documentation so I just guessed by looking the torture code
> in samba and the smbclient and to see what order to punch the
> lpcfg_stuff to make smbcli_full_connection() not fail.
>
> On Tue, Jan 20, 2015 at 2:33 PM, Jens Axboe <axboe@kernel.dk> wrote:
>> On 01/19/2015 08:31 AM, Jens Axboe wrote:
>>>
>>> I didn't look at your code yet, but I'm assuming it's a self contained
>>> IO engine. So we should be able to make that work, by only linking the
>>> engine itself against libsmbclient. But sheesh, what a pain in the butt,
>>> why can't we just all be friends.
>>
>>
>> I pulled it in for testing, and came up with this patch [1]. If you don't do
>> anything, it'll build cifs into fio as before. If you add --cifs-external to
>> the configure arguments, it'll build cifs.so as an externally loadable
>> module. You'd then use:
>>
>> ioengine=/path/to/cifs.so
>>
>> to use that module. I did not add an install target, I'll leave that to
>> distros...
>>
>> Let me know how that works for you. And let me know how far along you are
>> with the cifs engine, I'd like to pull it in.
>>
>> http://git.kernel.dk/?p=fio.git;a=shortlog;h=refs/heads/cifs
>>
>> [1]
>> http://git.kernel.dk/?p=fio.git;a=commit;h=c2c05e33b753ae686e24b43d1034d0c474203729
>>
>> --
>> Jens Axboe
>>
>
>
>
> --
> Milosz Tanski
> CTO
> 16 East 34th Street, 15th floor
> New York, NY 10016
>
> p: 646-253-9055
> e: milosz@adfin.com



-- 
Milosz Tanski
CTO
16 East 34th Street, 15th floor
New York, NY 10016

p: 646-253-9055
e: milosz@adfin.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
