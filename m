Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 72DDD6B0023
	for <linux-mm@kvack.org>; Tue,  3 May 2011 16:11:04 -0400 (EDT)
Received: by iwg8 with SMTP id 8so561640iwg.14
        for <linux-mm@kvack.org>; Tue, 03 May 2011 13:11:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201105032202.42662.arnd@arndb.de>
References: <BANLkTinhK_K1oSJDEoqD6EQK8Qy5Wy3v+g@mail.gmail.com>
	<201105031516.28907.arnd@arndb.de>
	<BANLkTi=74Mp1vWBt2F-sqqqkeNfP69+9vg@mail.gmail.com>
	<201105032202.42662.arnd@arndb.de>
Date: Tue, 3 May 2011 22:11:02 +0200
Message-ID: <BANLkTinJxkauY+WUnJet+T5QM4_ROiKzGQ@mail.gmail.com>
Subject: Re: mmc blkqueue is empty even if there are pending reads in do_generic_file_read()
From: Per Forlin <per.forlin@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-mm@kvack.org, linux-mmc@vger.kernel.org, linaro-kernel@lists.linaro.org

On 3 May 2011 22:02, Arnd Bergmann <arnd@arndb.de> wrote:
> On Tuesday 03 May 2011 20:54:43 Per Forlin wrote:
>> >> page_not_up_to_date:
>> >> /* Get exclusive access to the page ... */
>> >> error =3D lock_page_killable(page);
>> > I looked at the code in do_generic_file_read(). lock_page_killable
>> > waits until the current read ahead is completed.
>> > Is it possible to configure the read ahead to push multiple read
>> > request to the block device queue?add
>
> I believe sleeping in __lock_page_killable is the best possible scenario.
> Most cards I've seen work best when you use at least 64KB reads, so it wi=
ll
> be faster to wait there than to read smaller units.
>
>> When I first looked at this I used dd if=3D/dev/mmcblk0 of=3D/dev/null b=
s=3D1M count=3D4
>> If bs is larger than read ahead, this will make the execution loop in
>> do_generic_file_read() reading 512 until 1M is read. The second time
>> in this loop it will wait on lock_page_killable.
>>
>> If bs=3D16k the execution wont stuck at lock_page_killable.
>
> submitting small 512 byte read requests is a real problem when the
> underlying page size is 16 KB. If your interpretation is right,
> we should probably find a way to make it read larger chunks
> on flash media.
Sorry a typo. I missed out a "k" :)
It reads 512k until 1M.

>
> =A0 =A0 =A0 =A0Arnd
>
Per

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
