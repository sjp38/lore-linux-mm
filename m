Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1D46B0071
	for <linux-mm@kvack.org>; Sun, 11 Jan 2015 00:46:29 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id l18so14304134wgh.0
        for <linux-mm@kvack.org>; Sat, 10 Jan 2015 21:46:29 -0800 (PST)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0064.outbound.protection.outlook.com. [157.55.234.64])
        by mx.google.com with ESMTPS id k11si6824918wiv.63.2015.01.10.21.46.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 10 Jan 2015 21:46:28 -0800 (PST)
Message-ID: <54B20DEA.5050803@mellanox.com>
Date: Sun, 11 Jan 2015 07:45:14 +0200
From: Haggai Eran <haggaie@mellanox.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/6] HMM: add per mirror page table.
References: <1420497889-10088-1-git-send-email-j.glisse@gmail.com>
 <1420497889-10088-6-git-send-email-j.glisse@gmail.com>
 <54AE6485.60402@mellanox.com> <20150110064831.GA19689@gmail.com>
In-Reply-To: <20150110064831.GA19689@gmail.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind
 Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John
 Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?windows-1252?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

On 10/01/2015 08:48, Jerome Glisse wrote:
> On Thu, Jan 08, 2015 at 01:05:41PM +0200, Haggai Eran wrote:
>> On 06/01/2015 00:44, j.glisse@gmail.com wrote:
>>> +	/* fence_wait() - to wait on device driver fence.
>>> +	 *
>>> +	 * @fence: The device driver fence struct.
>>> +	 * Returns: 0 on success,-EIO on error, -EAGAIN to wait again.
>>> +	 *
>>> +	 * Called when hmm want to wait for all operations associated with a
>>> +	 * fence to complete (including device cache flush if the event mandate
>>> +	 * it).
>>> +	 *
>>> +	 * Device driver must free fence and associated resources if it returns
>>> +	 * something else thant -EAGAIN. On -EAGAIN the fence must not be free
>>> +	 * as hmm will call back again.
>>> +	 *
>>> +	 * Return error if scheduled operation failed or if need to wait again.
>>> +	 * -EIO Some input/output error with the device.
>>> +	 * -EAGAIN The fence not yet signaled, hmm reschedule waiting thread.
>>> +	 *
>>> +	 * All other return value trigger warning and are transformed to -EIO.
>>> +	 */
>>> +	int (*fence_wait)(struct hmm_fence *fence);
>>
>> According to the comment, the device frees the fence struct when the
>> fence_wait callback returns zero or -EIO, but the code below calls
>> fence_unref after fence_wait on the same fence.
> 
> Yes comment is out of date, i wanted to simplify fence before readding
> it once needed (by device memory migration).
> 
>>
>>> +
>>> +	/* fence_ref() - take a reference fence structure.
>>> +	 *
>>> +	 * @fence: Fence structure hmm is referencing.
>>> +	 */
>>> +	void (*fence_ref)(struct hmm_fence *fence);
>>
>> I don't see fence_ref being called anywhere in the patchset. Is it
>> actually needed?
> 
> Not right now but the page migration to device memory use it. But i
> can remove it now.
> 
> I can respin to make comment match code but i would like to know where
> i stand on everythings else.
> 

Well, I've read patches 1 through 4, and they seemed fine, although I
still want to have a deeper look into patch 4, because the page table
code seems a little tricky. I haven't completed reading patch 5 and 6 yet.

Haggai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
