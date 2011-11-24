Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D85926B00AA
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 22:22:56 -0500 (EST)
Message-ID: <4ECDB87A.90106@redhat.com>
Date: Thu, 24 Nov 2011 11:22:34 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [V3 PATCH 1/2] tmpfs: add fallocate support
References: <1322038412-29013-1-git-send-email-amwang@redhat.com>	<20111124105245.b252c65f.kamezawa.hiroyu@jp.fujitsu.com>	<CAHGf_=oD0Coc=k5kAAQoP=GqK+nc0jd3qq3TmLZaitSjH-ZPmQ@mail.gmail.com> <20111124120126.9361b2c9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111124120126.9361b2c9.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Christoph Hellwig <hch@lst.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, linux-mm@kvack.org

ao? 2011a1'11ae??24ae?JPY 11:01, KAMEZAWA Hiroyuki a??e??:
> On Wed, 23 Nov 2011 21:46:39 -0500
> KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>  wrote:
>
>>>> +     while (index<  end) {
>>>> +             ret = shmem_getpage(inode, index,&page, SGP_WRITE, NULL);
>>>
>>> If the 'page' for index exists before this call, this will return the page without
>>> allocaton.
>>>
>>> Then, the page may not be zero-cleared. I think the page should be zero-cleared.
>>
>> No. fallocate shouldn't destroy existing data. It only ensure
>> subsequent file access don't make ENOSPC error.
>>
>        FALLOC_FL_KEEP_SIZE
>                This flag allocates and initializes to zero the disk  space
>                within the range specified by offset and len. ....
>
> just manual is unclear ? it seems that the range [offset, offset+len) is
> zero cleared after the call.

I think we should fix the man page, because at least ext4 doesn't clear
the original contents,

% echo hi > /tmp/foobar
% fallocate -n -l 1 -o 10 /tmp/foobar
% hexdump -Cv /tmp/foobar
00000000  68 69 0a                                          |hi.|
00000003

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
