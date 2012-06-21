Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id E50916B004D
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 21:45:49 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Thu, 21 Jun 2012 07:15:46 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5L1j11O1114450
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 07:15:01 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5L7Emgk012986
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 17:14:48 +1000
Message-ID: <4FE27C9B.2070500@linux.vnet.ibm.com>
Date: Thu, 21 Jun 2012 09:44:59 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/10] zcache: fix refcount leak
References: <4FE0392E.3090300@linux.vnet.ibm.com> <4FE03949.4080308@linux.vnet.ibm.com> <4FE08C9A.3010701@linux.vnet.ibm.com> <c10bcaf9-aa56-4d6a-bc2c-310096b4198b@default> <4FE0DBDD.2090005@linux.vnet.ibm.com> <4FE13B76.6020703@linux.vnet.ibm.com> <4FE14149.7030807@linux.vnet.ibm.com> <db70ea46-7e43-4795-a399-c3220cda0a46@default>
In-Reply-To: <db70ea46-7e43-4795-a399-c3220cda0a46@default>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>

On 06/21/2012 06:25 AM, Dan Magenheimer wrote:

>> From: Xiao Guangrong [mailto:xiaoguangrong@linux.vnet.ibm.com]
>> Subject: Re: [PATCH 02/10] zcache: fix refcount leak
>>
>> On 06/20/2012 10:54 AM, Xiao Guangrong wrote:
>>
>>> On 06/20/2012 04:06 AM, Seth Jennings wrote:
>>>
>>>> On 06/19/2012 02:49 PM, Dan Magenheimer wrote:
>>>>
>>>>> My preference would be to fix it the opposite way, by
>>>>> checking and ignoring zcache_host in zcache_put_pool.
>>>>> The ref-counting is to ensure that a client isn't
>>>>> accidentally destroyed while in use (for multiple-client
>>>>> users such as ramster and kvm) and since zcache_host is a static
>>>>> struct, it should never be deleted so need not be ref-counted.
>>>>
>>>>
>>>> If we do that, we'll need to comment it.  If we don't, it won't be
>>>> obvious why we are refcounting every zcache client except one.  It'll
>>>> look like a bug.
>>>
>>>
>>> Okay, i will fix it like Dan's way and comment it.
>>
>> Hmm...But i notice that zcache_host is the same as other clients, all
>> of them are static struct:
>>
>> | static struct zcache_client zcache_host;
>> | static struct zcache_client zcache_clients[MAX_CLIENTS];
>>
>> And all of them are not destroyed.
> 
> Yes, the code currently in zcache was a first step towards
> supporting multiple clients.  Ramster goes one step further
> and kvm will require even a tiny bit more work.
> 


So, do you mind we increase the refcount for all clients (zcache host and
other clients) first? Like my origin patch?

> FYI, I'm working on a unification version of zcache that can support
> all of these cleanly as well as better support for eviction
> that will make standalone zcache more suitable for promotion from
> staging and enterprise-ready.  Due to various summer commitments,
> it will probably be a few weeks before it is ready for posting.


Great work, look forward to the progress! :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
