Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4A3486B01DC
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 05:54:34 -0400 (EDT)
Message-ID: <4C174DD7.3000608@redhat.com>
Date: Tue, 15 Jun 2010 12:54:31 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page cache
 control
References: <20100610142512.GB5191@balbir.in.ibm.com> <1276214852.6437.1427.camel@nimitz> <20100611045600.GE5191@balbir.in.ibm.com> <4C15E3C8.20407@redhat.com> <20100614084810.GT5191@balbir.in.ibm.com> <1276528376.6437.7176.camel@nimitz> <20100614165853.GW5191@balbir.in.ibm.com> <1276535371.6437.7417.camel@nimitz> <20100614171624.GY5191@balbir.in.ibm.com> <4C1727EC.2020500@redhat.com> <20100615075210.GB4306@balbir.in.ibm.com>
In-Reply-To: <20100615075210.GB4306@balbir.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 06/15/2010 10:52 AM, Balbir Singh wrote:
>>>
>>> That is why the policy (in the next set) will come from the host. As
>>> to whether the data is truly duplicated, my experiments show up to 60%
>>> of the page cache is duplicated.
>>>        
>> Isn't that incredibly workload dependent?
>>
>> We can't expect the host admin to know whether duplication will
>> occur or not.
>>
>>      
> I was referring to cache = (policy) we use based on the setup. I don't
> think the duplication is too workload specific. Moreover, we could use
> aggressive policies and restrict page cache usage or do it selectively
> on ballooning. We could also add other options to make the ballooning
> option truly optional, so that the system management software decides.
>    

Consider a read-only workload that exactly fits in guest cache.  Without 
trimming, the guest will keep hitting its own cache, and the host will 
see no access to the cache at all.  So the host (assuming it is under 
even low pressure) will evict those pages, and the guest will happily 
use its own cache.  If we start to trim, the guest will have to go to 
disk.  That's the best case.

Now for the worst case.  A random access workload that misses the cache 
on both guest and host.  Now every page is duplicated, and trimming 
guest pages allows the host to increase its cache, and potentially 
reduce misses.  In this case trimming duplicated pages works.

Real life will see a mix of this.  Often used pages won't be duplicated, 
and less often used pages may see some duplication, especially if the 
host cache portion dedicated to the guest is bigger than the guest cache.

I can see that trimming duplicate pages helps, but (a) I'd like to be 
sure they are duplicates and (b) often trimming them from the host is 
better than trimming them from the guest.

Trimming from the guest is worthwhile if the pages are not used very 
often (but enough that caching them in the host is worth it) and if the 
host cache can serve more than one guest.  If we can identify those 
pages, we don't risk degrading best-case workloads (as defined above).

(note ksm to some extent identifies those pages, though it is a bit 
expensive, and doesn't share with the host pagecache).

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
