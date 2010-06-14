Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B27AA6B01E8
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 11:33:35 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5EFPaZk010606
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 09:25:36 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o5EFXIog124238
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 09:33:19 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5EFXICf015753
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 09:33:18 -0600
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page
 cache control
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4C162846.7030303@redhat.com>
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>
	 <20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com>
	 <4C10B3AF.7020908@redhat.com> <20100610142512.GB5191@balbir.in.ibm.com>
	 <1276214852.6437.1427.camel@nimitz>
	 <20100611045600.GE5191@balbir.in.ibm.com> <4C15E3C8.20407@redhat.com>
	 <20100614084810.GT5191@balbir.in.ibm.com> <4C16233C.1040108@redhat.com>
	 <20100614125010.GU5191@balbir.in.ibm.com>  <4C162846.7030303@redhat.com>
Content-Type: text/plain
Date: Mon, 14 Jun 2010 08:33:16 -0700
Message-Id: <1276529596.6437.7216.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: balbir@linux.vnet.ibm.com, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-14 at 16:01 +0300, Avi Kivity wrote:
> If we drop unmapped pagecache pages, we need to be sure they can be 
> backed by the host, and that depends on the amount of sharing.

You also have to set up the host up properly, and continue to maintain
it in a way that finds and eliminates duplicates.

I saw some benchmarks where KSM was doing great, finding lots of
duplicate pages.  Then, the host filled up, and guests started
reclaiming.  As memory pressure got worse, so did KSM's ability to find
duplicates.

At the same time, I see what you're trying to do with this.  It really
can be an alternative to ballooning if we do it right, since ballooning
would probably evict similar pages.  Although it would only work in idle
guests, what about a knob that the host can turn to just get the guest
to start running reclaim?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
