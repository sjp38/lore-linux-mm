Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id AFE716B0044
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 15:43:16 -0400 (EDT)
Received: by yenm8 with SMTP id m8so2283133yen.14
        for <linux-mm@kvack.org>; Thu, 29 Mar 2012 12:43:15 -0700 (PDT)
Message-ID: <4F74BB67.30703@gmail.com>
Date: Thu, 29 Mar 2012 15:43:35 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] do_migrate_pages() calls migrate_to_node() even if
 task is already on a correct node
References: <4F6B6BFF.1020701@redhat.com> <4F6B7358.60800@gmail.com> <alpine.DEB.2.00.1203221348470.25011@router.home> <4F6B7854.1040203@redhat.com> <alpine.DEB.2.00.1203221421570.25011@router.home> <4F74A344.7070805@redhat.com>
In-Reply-To: <4F74A344.7070805@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lwoodman@redhat.com
Cc: Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Motohiro Kosaki <mkosaki@redhat.com>kosaki.motohiro@gmail.com

(3/29/12 2:00 PM), Larry Woodman wrote:
> On 03/22/2012 03:30 PM, Christoph Lameter wrote:
>> On Thu, 22 Mar 2012, Larry Woodman wrote:
>>
>>>> Application may manage their locality given a range of nodes and each of
>>>> the x .. x+n nodes has their particular purpose.
>>> So to be clear on this, in that case the intention would be move 3 to 4, 4 to
>>> 5 and 5 to 6
>>> to keep the node ordering the same?
>> Yup. Have a look at do_migrate_pages and the descrition in the comment by
>> there by Paul Jackson.
>>
>>
> Christoph and others what do you think about this???
>
>
> 		for_each_node_mask(s, tmp) {
>+
>+			/* IFF there is an equal number of source and
>+			 * destination nodes, maintain relative node distance
>+			 * even when source and destination nodes overlap.
>+			 * However, when the node weight is unequal, never move
>+			 * memory out of any destination nodes */
>+			if ((nodes_weight(*from_nodes) != nodes_weight(*to_nodes)) &&
>+						(node_isset(s, *to_nodes)))
>+				continue;
>+
> 			d = node_remap(s, *from_nodes, *to_nodes);
> 			if (s == d)
> 				continue;

I'm confused. Could you please explain why you choose nodes_weight()? On my first impression,
it seems almostly unrelated factor.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
