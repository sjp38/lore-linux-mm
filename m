Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id C0CF26B0087
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 15:06:55 -0400 (EDT)
Message-ID: <509025ED.8050207@redhat.com>
Date: Tue, 30 Oct 2012 15:09:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm,vmscan: only evict file pages when we have plenty
References: <20121030144204.0aa14d92@dull> <20121030115451.f4c097f0.akpm@linux-foundation.org>
In-Reply-To: <20121030115451.f4c097f0.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, klamm@yandex-team.ru, mgorman@suse.de, hannes@cmpxchg.org

On 10/30/2012 02:54 PM, Andrew Morton wrote:
> On Tue, 30 Oct 2012 14:42:04 -0400
> Rik van Riel <riel@redhat.com> wrote:
>
>> If we have more inactive file pages than active file pages, we
>> skip scanning the active file pages alltogether, with the idea
>> that we do not want to evict the working set when there is
>> plenty of streaming IO in the cache.
>
> Yes, I've never liked that.  The "(active > inactive)" thing is a magic
> number.  And suddenly causing a complete cessation of vm scanning at a
> particular magic threshold seems rather crude, compared to some complex
> graduated thing which will also always do the wrong thing, only more
> obscurely ;)
>
> Ho hum, in the absence of observed problems, I guess we don't muck with
> it.

The thing is, when we "suddenly switch behaviour" back to
scanning all the lists, that does not have to suddenly
lead to pages from the other lists being actually evicted.

Instead, it will lead to referenced inactive_anon pages
being moved back to the active_anon list, and any pages
from the end of the active_file list being moved to the
inactive_file list.

There is a threshold, and Johannes has patches to set
the threshold in a much more intelligent way, but the
change in behaviour should not be sudden due to the
inactive lists providing a rather large buffer.

When the VM is bouncing around the threshold, it should
look like a reduction in the rate at which the other
lists are scanned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
