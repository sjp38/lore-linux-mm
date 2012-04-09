Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id E59D66B0044
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 14:56:09 -0400 (EDT)
Message-ID: <4F8326FD.8020507@redhat.com>
Date: Mon, 09 Apr 2012 14:14:21 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: mapped pagecache pages vs unmapped pages
References: <37371333672160@webcorp7.yandex-team.ru> <4F7E9854.1020904@gmail.com> <12701333991475@webcorp7.yandex-team.ru>
In-Reply-To: <12701333991475@webcorp7.yandex-team.ru>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Ivanov <rbtz@yandex-team.ru>
Cc: "gnehzuil.lzheng@gmail.com" <gnehzuil.lzheng@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04/09/2012 01:11 PM, Alexey Ivanov wrote:
> Thanks for the hint!
>
> Can anyone clarify the reason of not using zone->inactive_ratio in inactive_file_is_low_global()?

New anonymous pages start out on the active anon list, and
are always referenced.  If memory fills up, they may end
up getting moved to the inactive anon list; being referenced
while on the inactive anon list is enough to get them promoted
back to the active list.

New file pages start out on the INACTIVE file list, and
start their lives not referenced at all. Due to readahead
extra reads, many file pages may never be referenced.

Only file pages that are referenced twice make it onto
the active list.

This means the inactive file list has to be large enough
for all the readahead buffers, and give pages enough time
on the list that frequently accessed ones can get accessed
twice and promoted.

http://linux-mm.org/PageReplacementDesign

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
