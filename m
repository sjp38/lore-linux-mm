Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 792B46B002B
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 21:42:26 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <john.stultz@linaro.org>;
	Mon, 8 Oct 2012 19:42:25 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id ECD023E4003D
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 19:42:19 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q991gMkp225642
	for <linux-mm@kvack.org>; Mon, 8 Oct 2012 19:42:22 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q991gLQc012825
	for <linux-mm@kvack.org>; Mon, 8 Oct 2012 19:42:22 -0600
Message-ID: <507380F8.4000401@linaro.org>
Date: Mon, 08 Oct 2012 18:42:16 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [RFC] vmevent: Implement pressure attribute
References: <20121004110524.GA1821@lizard> <20121005092912.GA29125@suse.de> <20121007081414.GA18047@lizard> <20121008094646.GI29125@suse.de>
In-Reply-To: <20121008094646.GI29125@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Colin Cross <ccross@android.com>, Arve Hj?nnev?g <arve@android.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On 10/08/2012 02:46 AM, Mel Gorman wrote:
> On Sun, Oct 07, 2012 at 01:14:17AM -0700, Anton Vorontsov wrote:
>> And here we just try to let userland to assist, userland can tell "oh,
>> don't bother with swapping or draining caches, I can just free some
>> memory".
>>
>> Quite interesting, this also very much resembles volatile mmap ranges
>> (i.e. the work that John Stultz is leading in parallel).
>>
> Agreed. I haven't been paying close attention to those patches but it
> seems to me that one possiblity is that a listener for a vmevent would
> set volatile ranges in response.

I don't have too much to comment on the rest of this mail, but just 
wanted to pipe in here, as the volatile ranges have caused some confusion.

While your suggestion would be possible, with volatile ranges, I've been 
promoting a more hands off-approach from the application perspective, 
where the application always would mark data that could be regenerated 
as volatile, unmarking it when accessing it.

This way the application doesn't need to be responsive to memory 
pressure, the kernel just takes what it needs from what the application 
made available.

Only when the application needs the data again, would it mark it 
non-volatile (or alternatively with the new SIGBUS semantics, access the 
purged volatile data and catch a SIGBUS), find the data was purged and 
regenerate it.

That said, hybrid approaches like you suggested would be possible, but 
at a certain point, if we're waiting for a notification to take action, 
it might be better just to directly free that memory, rather then just 
setting it as volatile, and leaving it to the kernel then reclaim it for 
you.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
