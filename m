Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id BC8B16B0078
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 23:23:14 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Wed, 20 Jun 2012 03:14:30 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5K3Je0r64094208
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 13:19:41 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5K3Je8A027965
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 13:19:40 +1000
Message-ID: <4FE14149.7030807@linux.vnet.ibm.com>
Date: Wed, 20 Jun 2012 11:19:37 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/10] zcache: fix refcount leak
References: <4FE0392E.3090300@linux.vnet.ibm.com> <4FE03949.4080308@linux.vnet.ibm.com> <4FE08C9A.3010701@linux.vnet.ibm.com> <c10bcaf9-aa56-4d6a-bc2c-310096b4198b@default> <4FE0DBDD.2090005@linux.vnet.ibm.com> <4FE13B76.6020703@linux.vnet.ibm.com>
In-Reply-To: <4FE13B76.6020703@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>

On 06/20/2012 10:54 AM, Xiao Guangrong wrote:

> On 06/20/2012 04:06 AM, Seth Jennings wrote:
> 
>> On 06/19/2012 02:49 PM, Dan Magenheimer wrote:
>>
>>> My preference would be to fix it the opposite way, by
>>> checking and ignoring zcache_host in zcache_put_pool.
>>> The ref-counting is to ensure that a client isn't
>>> accidentally destroyed while in use (for multiple-client
>>> users such as ramster and kvm) and since zcache_host is a static
>>> struct, it should never be deleted so need not be ref-counted.
>>
>>
>> If we do that, we'll need to comment it.  If we don't, it won't be
>> obvious why we are refcounting every zcache client except one.  It'll
>> look like a bug.
> 
> 
> Okay, i will fix it like Dan's way and comment it.


Hmm...But i notice that zcache_host is the same as other clients, all
of them are static struct:

| static struct zcache_client zcache_host;
| static struct zcache_client zcache_clients[MAX_CLIENTS];

And all of them are not destroyed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
