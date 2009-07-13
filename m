Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0AF3D6B0055
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 07:08:17 -0400 (EDT)
Message-ID: <4A5B1B9F.20708@redhat.com>
Date: Mon, 13 Jul 2009 14:33:51 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] Re: [RFC PATCH 0/4] (Take 2): transcendent memory
 ("tmem") for Linux
References: <d05df0b0-e932-4525-8c9e-93f6cb792903@default>
In-Reply-To: <d05df0b0-e932-4525-8c9e-93f6cb792903@default>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org, dave.mccracken@oracle.com, linux-mm@kvack.org, sunil.mushran@oracle.com, alan@lxorguk.ukuu.org.uk, Anthony Liguori <anthony@codemonkey.ws>, Schwidefsky <schwidefsky@de.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, chris.mason@oracle.com, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On 07/13/2009 12:08 AM, Dan Magenheimer wrote:
>> Can you explain how it differs for the swap case?  Maybe I don't
>> understand how tmem preswap works.
>>      
>
> The key differences I see are the "please may I store something"
> API and the fact that the reply (yes or no) can vary across time
> depending on the state of the collective of guests.  Virtual
> disk cacheing requires the host to always say yes and always
> deliver persistence.

We need to compare tmem+swap to swap+cache, not just tmem to cache.  
Here's how I see it:

tmem+swap swapout:
   - guest copies page to tmem (may fail)
   - guest writes page to disk

cached drive swapout:
   - guest writes page to disk
   - host copies page to cache

tmem+swap swapin:
   - guest reads page from tmem (may fail)
   - on tmem failure, guest reads swap from disk
   - guest drops tmem page

cached drive swapin:
   - guest reads page from disk
   - host may satisfy read from cache

tmem+swap ageing:
   - host may drop tmem page at any time

cached drive ageing:
   - host may drop cached page at any time

So they're pretty similar.  The main difference is that tmem can drop 
the page on swapin.  It could be made to work with swap by supporting 
the TRIM command.

> I can see that this is less of a concern
> for KVM because the host can swap... though doesn't this hide
> information from the guest and potentially have split-brain
> swapping issues?
>    

Double swap is bad for performance, yes.  CMM2 addresses it nicely.  
tmem doesn't address it at all - it assumes you have excess memory.

> (thanks for the great discussion so far... going offline mostly now
> for a few days)
>    

I'm going offline too so it cancels out.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
