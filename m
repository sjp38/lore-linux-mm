Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 829D26B0002
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 12:18:06 -0500 (EST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Mon, 4 Mar 2013 10:18:00 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 80A7D19D80A8
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 10:06:13 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r24H697m270360
	for <linux-mm@kvack.org>; Mon, 4 Mar 2013 10:06:10 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r24H68cb013124
	for <linux-mm@kvack.org>; Mon, 4 Mar 2013 10:06:08 -0700
Message-ID: <5134D476.3040302@linux.vnet.ibm.com>
Date: Mon, 04 Mar 2013 09:05:58 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mm: Export split_page().
References: <1362364075-14564-1-git-send-email-kys@microsoft.com> <20130304020747.GA8265@kroah.com> <3a362e994ab64efda79ae3c80342db95@SN2PR03MB061.namprd03.prod.outlook.com> <20130304022508.GA8638@kroah.com> <b863089d05f442fb9dfc90faa158a001@SN2PR03MB061.namprd03.prod.outlook.com>
In-Reply-To: <b863089d05f442fb9dfc90faa158a001@SN2PR03MB061.namprd03.prod.outlook.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KY Srinivasan <kys@microsoft.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/03/2013 06:36 PM, KY Srinivasan wrote:
>> I guess the most obvious question about exporting this symbol is, "Why
>> doesn't any of the other hypervisor balloon drivers need this?  What is
>> so special about hyper-v?"
> 
> The balloon protocol that Hyper-V has specified is designed around the ability to
> move 2M pages. While the protocol can handle 4k allocations, it is going to be very chatty
> with 4K allocations.

What does "very chatty" mean?  Do you think that there will be a
noticeable performance difference ballooning 2M pages vs 4k?

> Furthermore, the Memory Balancer on the host is also designed to work
> best with memory moving around in 2M chunks. While I have not seen the code on the Windows
> host that does this memory balancing, looking at how Windows guests behave in this environment,
> (relative to Linux) I have to assume that the 2M allocations that Windows guests do are a big part of
> the difference we see.

You've been talking about differences.  Could you elaborate on what the
differences in behavior are that you are trying to rectify here?

>> Or can those other drivers also need/use it as well, and they were just
>> too chicken to be asking for the export?  :)
> 
> The 2M balloon allocations would make sense if the host is designed accordingly.

How does the guest decide which size pages to allocate?  It seems like a
relatively bad idea to be inflating the balloon with 2M pages from the
guest in the case where the guest is under memory pressure _and_
fragmented.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
