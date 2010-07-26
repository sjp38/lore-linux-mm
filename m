Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7A14D6007FA
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 10:06:31 -0400 (EDT)
Received: by pzk33 with SMTP id 33so1225497pzk.14
        for <linux-mm@kvack.org>; Mon, 26 Jul 2010 07:06:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1006011351400.13136@chino.kir.corp.google.com>
References: <AANLkTimAF1zxXlnEavXSnlKTkQgGD0u9UqCtUVT_r9jV@mail.gmail.com>
	<AANLkTimUYmUCdFMIaVi1qqcz2DqGoILeu43XWZBHSILP@mail.gmail.com>
	<AANLkTilmr29Vv3N64n7KVj9fSDpfBHIt8-quxtEwY0_X@mail.gmail.com>
	<alpine.LSU.2.00.1005211410170.14789@sister.anvils> <AANLkTil8sEzrsC9If5HdU8S5R-sK84_fUt_BXUDcAu0J@mail.gmail.com>
	<alpine.DEB.2.00.1006011351400.13136@chino.kir.corp.google.com>
From: dave b <db.pub.mail@gmail.com>
Date: Tue, 27 Jul 2010 00:05:55 +1000
Message-ID: <AANLkTikUO+WMHXqTMc7jR84UMgKidzX5d5JX6q=DvmpY@mail.gmail.com>
Subject: Re: PROBLEM: oom killer and swap weirdness on 2.6.3* kernels
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 2 June 2010 06:52, David Rientjes <rientjes@google.com> wrote:
> On Thu, 27 May 2010, dave b wrote:
>
>> That was just a simple test case with dd. That test case might be
>> invalid - but it is trying to trigger out of memory - doing this any
>> other way still causes the problem. I note that playing with some bios
>> settings I was actually able to trigger what appeared to be graphics
>> corruption issues when I launched kde applications ... nothing shows
>> up in dmesg so this might just be a conflict between xorg and the
>> kernel with those bios settings...
>>
>> Anyway, This is no longer a 'problem' for me since I disabled
>> overcommit and altered the values for dirty_ratio and
>> dirty_background_ratio - and I cannot trigger it.
>>
>
> Disabling overcommit should always do it, but I'd be interested to know if
> restoring dirty_ratio to 40 would help your usecase.
>
Actually it turns out on 2.6.34.1 I can trigger this issue. What it
really is, is that linux doesn't invoke the oom killer when it should
and kill something off. This is *really* annoying.

I used the follow script - (on 2.6.34.1)
cat ./scripts/disable_over_commit
#!/bin/bash
echo 2 > /proc/sys/vm/overcommit_memory
echo 40 > /proc/sys/vm/dirty_ratio
echo 5 > /proc/sys/vm/dirty_background_ratio

And I was still able to reproduce this bug.
Here is some c  code to trigger the condition I am talking about.


#include <stdlib.h>
#include <stdio.h>

int main(void)
{
	while(1)
	{
		malloc(1000);
	}

	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
