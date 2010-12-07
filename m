Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8901B6B0087
	for <linux-mm@kvack.org>; Mon,  6 Dec 2010 21:16:03 -0500 (EST)
Received: by iwn5 with SMTP id 5so456280iwn.14
        for <linux-mm@kvack.org>; Mon, 06 Dec 2010 18:16:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87mxoi9wnf.fsf@gmail.com>
References: <cover.1291568905.git.minchan.kim@gmail.com>
	<AANLkTim71krrCcmhTTCZTzxeUDkvOdBTOkeYQu6EXt32@mail.gmail.com>
	<87mxoi9wnf.fsf@gmail.com>
Date: Tue, 7 Dec 2010 11:16:01 +0900
Message-ID: <AANLkTimp-Kw9_9oEh1JnA4LDbJ+EjUxd9MdHwVep0rbE@mail.gmail.com>
Subject: Re: [PATCH v4 0/7] f/madivse(DONTNEED) support
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari.foss@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ben,
Thanks for the testing.

On Tue, Dec 7, 2010 at 10:52 AM, Ben Gamari <bgamari.foss@gmail.com> wrote:
> On Tue, 7 Dec 2010 09:24:54 +0900, Minchan Kim <minchan.kim@gmail.com> wr=
ote:
>> Sorry missing you in Cc.
>>
>> Ben. Could you test this series?
>> You don't need to apply patch all so just apply 2,3,4,5.
>> This patches are based on mmotm-12-02 so if you suffered this patches
>> from applying your kernel, I can help you. :)
>>
> I am very sorry for my lack of responsiveness. It's the last week of the
> semester so things have been a bit busy. Nevertheless, I did do some
> testing on v3 of the patch last week. Unfortunately, the results weren't
> so promising, although this very well could be due to problems with my
> test. For both patched and unpatched rsyncs and kernels I did roughly
> the following,
>
> =A0$ rm -Rf $DEST
> =A0$ cat /proc/vmstat > vmstat-pre
> =A0$ time rsync -a $SRC $DEST
> =A0$ cat /proc/vmstat > vmstat-post
> =A0$ time rsync -a $SRC $DEST
> =A0$ cat /proc/vmstat > vmstat-post-warm
>
> Where $DEST and $SRC both reside on local a SATA drive (hdparm reports
> read speeds of about 100MByte/sec). I ran this (test.sh) three times on
> both a patched kernel (2.6.37-rc3) and an unpatched kernel
> (2.6.37-rc3-mm1). The results can be found in the attached tarball.

1. 2.6.37-rc3?
2. 2.6.37-rc3-mm1?
3. 2.6.37-rc3-mm1-fadvise patch?

Maybe you test it on 2, 3.
To be clear, what is kernels you used?

>
> Judging by the results, something is horribly wrong. The "drop" (patched
> rsync) runtimes are generally 3x longer than the "nodrop" (unpatched
> rsync) runtimes in the case of the patched kernel. This suggests that
> rsync is doing something I did not anticipate.

Does it take 3x longer in non-patched kernel?
If your workload doesn't use huge memory, fadvise(dontneed) may have
longer time because it have to invalidate the page.
In that case, the purpose isn't the performance but prevent eviction
working set page of other processes.
If your workload uses huge memory, it can help performance, too
because it help that reclaimer can reclaim unnecessary pages and keep
the working set.

Note : in my v3 version, I didn't rotate the page already done
writeback in tail of inactive. But it is very likely to happen because
the pages are pagevec.

So I think v4 can help you more.
And please, attach cat /proc/vmstat with time result.

Again, Thanks for the tesing, Ben.


>
> I'll redo the test tonight with v4 of the patch and will
> investigate the source of the performance drop as soon as the
> school-related workload subsides.
>
> Cheers,
>
> - Ben
>
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
