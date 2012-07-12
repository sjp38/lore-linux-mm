Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 288F46B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 20:25:08 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 11 Jul 2012 18:25:07 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 6BB1719D804A
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 00:24:28 +0000 (WET)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6C0NkUd006308
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 18:24:03 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6C0NUQs024844
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 18:23:30 -0600
Message-ID: <4FFE18FF.6080307@linux.vnet.ibm.com>
Date: Wed, 11 Jul 2012 19:23:27 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] zsmalloc: remove x86 dependency
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com> <1341263752-10210-2-git-send-email-sjenning@linux.vnet.ibm.com> <4FFDC54F.5030402@vflare.org>	<4FFDE2E2.7050901@linux.vnet.ibm.com> <CAPkvG_fejGCrS9u3Mg-ic1B_ar5qdyCSKSQtweijwaZ5mou=dw@mail.gmail.com>
In-Reply-To: <CAPkvG_fejGCrS9u3Mg-ic1B_ar5qdyCSKSQtweijwaZ5mou=dw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 07/11/2012 05:42 PM, Nitin Gupta wrote:
> On Wed, Jul 11, 2012 at 1:32 PM, Seth Jennings
> <sjenning@linux.vnet.ibm.com> wrote:
>> On 07/11/2012 01:26 PM, Nitin Gupta wrote:
<snip>
>>> Now obj-1 lies completely within page-2, so can be kmap'ed as usual. On
>>> zs_unmap_object() we would just do the reverse and restore objects as in
>>> figure-1.
>>
>> Hey Nitin, thanks for the feedback.
>>
>> Correct me if I'm wrong, but it seems like you wouldn't be able to map
>> ob2 while ob1 was mapped with this design.  You'd need some sort of
>> zspage level protection against concurrent object mappings.  The
>> code for that protection might cancel any benefit you would gain by
>> doing it this way.
>>
> 
> Do you think blocking access of just one particular object (or
> blocking an entire zspage, for simplicity) for a short time would be
> an issue, apart from the complexity of implementing per zspage
> locking?

It would only need to prevent the mapping of the temporarily displaced
object, but I said zspage because I don't know how we would do
per-object locking.  I actually don't know how we would do zspage
locking either unless there is a lock in the struct page we can use.

Either way, I think it is a complexity I think we'd be better to avoid
for now.  I'm trying to get zsmalloc in shape to bring into mainline, so
I'm really focusing on portability first and low hanging performance
fruit second. This optimization would be more like top-of-the-tree
performance fruit :-/

However, if you want to try it out, don't let me stop you :)

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
