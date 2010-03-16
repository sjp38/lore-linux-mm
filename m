Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7D0056B00AA
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 05:06:01 -0400 (EDT)
Message-ID: <4B9F49F1.70202@redhat.com>
Date: Tue, 16 Mar 2010 11:05:53 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot parameter
References: <20100315072214.GA18054@balbir.in.ibm.com> <4B9DE635.8030208@redhat.com> <20100315080726.GB18054@balbir.in.ibm.com> <4B9DEF81.6020802@redhat.com> <20100315091720.GC18054@balbir.in.ibm.com> <4B9DFD9C.8030608@redhat.com> <4B9E810E.9010706@codemonkey.ws>
In-Reply-To: <4B9E810E.9010706@codemonkey.ws>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 03/15/2010 08:48 PM, Anthony Liguori wrote:
> On 03/15/2010 04:27 AM, Avi Kivity wrote:
>>
>> That's only beneficial if the cache is shared.  Otherwise, you could 
>> use the balloon to evict cache when memory is tight.
>>
>> Shared cache is mostly a desktop thing where users run similar 
>> workloads.  For servers, it's much less likely.  So a modified-guest 
>> doesn't help a lot here.
>
> Not really.  In many cloud environments, there's a set of common 
> images that are instantiated on each node.  Usually this is because 
> you're running a horizontally scalable application or because you're 
> supporting an ephemeral storage model.

But will these servers actually benefit from shared cache?  So the 
images are shared, they boot up, what then?

- apache really won't like serving static files from the host pagecache
- dynamic content (java, cgi) will be mostly in anonymous memory, not 
pagecache
- ditto for application servers
- what else are people doing?

> In fact, with ephemeral storage, you typically want to use 
> cache=writeback since you aren't providing data guarantees across 
> shutdown/failure.

Interesting point.

We'd need a cache=volatile for this use case to avoid the fdatasync()s 
we do now.  Also useful for -snapshot.  In fact I have a patch for this 
somewhere I can dig out.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
