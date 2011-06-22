Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C96FB900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 15:01:58 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p5MJ1s0g005119
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 12:01:54 -0700
Received: from qyg14 (qyg14.prod.google.com [10.241.82.142])
	by kpbe19.cbf.corp.google.com with ESMTP id p5MJ0NNN008388
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 12:01:52 -0700
Received: by qyg14 with SMTP id 14so2465479qyg.8
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 12:01:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E0230CD.1030505@zytor.com>
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de>
	<20110622110034.89ee399c.akpm@linux-foundation.org>
	<4E0230CD.1030505@zytor.com>
Date: Wed, 22 Jun 2011 12:01:50 -0700
Message-ID: <BANLkTinMrMcDw8KX3BxmZh12-kULmecT-s9gdRGpYUCfNjFO7Q@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
From: Nancy Yuen <yuenn@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Stefan Assmann <sassmann@kpanic.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, rick@vanrein.org, rdunlap@xenotime.net, Michael Ditto <mditto@google.com>

On Wed, Jun 22, 2011 at 11:13, H. Peter Anvin <hpa@zytor.com> wrote:
> On 06/22/2011 11:00 AM, Andrew Morton wrote:
>> :
>> : Second, the BadRAM patch expands the address patterns from the command
>> : line into individual entries in the kernel's e820 table. =A0The e820
>> : table is a fixed buffer that supports a very small, hard coded number
>> : of entries (128). =A0We require a much larger number of entries (on
>> : the order of a few thousand), so much of the google kernel patch deals
>> : with expanding the e820 table.
>
> This has not been true for a long time.

Good point.  There's the MAX_NODES that expands it, though it's still
hard coded, and as I understand, intended for NUMA node entries.  We
need anywhere from 8K to 64K 'bad' entries.  This creates holes and
translates to twice as many entries in the e820.  We only want to
allow this memory if it's needed, instead of hard coding it.

>
>> I have a couple of thoughts here:
>>
>> - If this patchset is merged and a major user such as google is
>> =A0 unable to use it and has to continue to carry a separate patch then
>> =A0 that's a regrettable situation for the upstream kernel.
>>
>> - Google's is, afaik, the largest use case we know of: zillions of
>> =A0 machines for a number of years. =A0And this real-world experience te=
lls
>> =A0 us that the badram patchset has shortcomings. =A0Shortcomings which =
we
>> =A0 can expect other users to experience.
>>
>> So. =A0What are your thoughts on these issues?
>
> I think a binary structure fed as a linked list data object makes a lot
> more sense. =A0We already support feeding e820 entries in this way,
> bypassing the 128-entry limitation of the fixed table in the zeropage.
>
> The main issue then is priority; in particular memory marked UNUSABLE
> (type 5) in the fed-in e820 map will of course overlap entries with
> normal RAM (type 1) information in the native map; we need to make sure
> that the type 5 information takes priority.
>
> =A0 =A0 =A0 =A0-hpa
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
