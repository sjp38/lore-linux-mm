Message-ID: <3F32108A.2010000@cyberone.com.au>
Date: Thu, 07 Aug 2003 18:40:42 +1000
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.0-test2-mm5
References: <20030806223716.26af3255.akpm@osdl.org>	<28050000.1060237907@[10.10.2.4]> <20030807000542.5cbf0a56.akpm@osdl.org> <3F320DFC.6070400@cyberone.com.au>
In-Reply-To: <3F320DFC.6070400@cyberone.com.au>
Content-Type: multipart/mixed;
 boundary="------------050008060307010204060504"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050008060307010204060504
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Andrew and or Martin, please test attached patch.
Thanks.

Nick Piggin wrote:

>
>
> Andrew Morton wrote:
>
>> "Martin J. Bligh" <mbligh@aracnet.com> wrote:
>>
>>> I get lots of these .... (without 4/4 turned on)
>>>
>>>  Badness in as_dispatch_request at drivers/block/as-iosched.c:1241
>>>
>>
>> yes, it happens with aic7xxx as well.  Sorry about that.
>>
>> You'll need to revert
>>
>
> Sorry. Worked with the sym53c8xx for me. I'll fix.
>

--------------050008060307010204060504
Content-Type: text/plain;
 name="as-mm5-fix"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="as-mm5-fix"

--- linux-2.6/drivers/block/as-iosched.c.orig	2003-08-07 18:33:06.000000000 +1000
+++ linux-2.6/drivers/block/as-iosched.c	2003-08-07 18:36:03.000000000 +1000
@@ -1198,8 +1198,10 @@ static int as_dispatch_request(struct as
 			 */
 			goto dispatch_writes;
 
- 		if (ad->batch_data_dir == REQ_ASYNC)
+ 		if (ad->batch_data_dir == REQ_ASYNC) {
+			WARN_ON(ad->new_batch || ad->changed_batch);
  			ad->changed_batch = 1;
+		}
 		ad->batch_data_dir = REQ_SYNC;
 		arq = list_entry_fifo(ad->fifo_list[ad->batch_data_dir].next);
 		ad->last_check_fifo[ad->batch_data_dir] = jiffies;
@@ -1214,8 +1216,17 @@ static int as_dispatch_request(struct as
 dispatch_writes:
 		BUG_ON(RB_EMPTY(&ad->sort_list[REQ_ASYNC]));
 
- 		if (ad->batch_data_dir == REQ_SYNC)
+ 		if (ad->batch_data_dir == REQ_SYNC) {
+			WARN_ON(ad->changed_batch);
  			ad->changed_batch = 1;
+
+			/*
+			 * new_batch might be 1 when the queue runs out of
+			 * reads. A subsequent submission of a write might
+			 * cause a change of batch before the read is finished.
+			 */
+			ad->new_batch = 0;
+		}
 		ad->batch_data_dir = REQ_ASYNC;
 		ad->current_write_count = ad->write_batch_count;
 		ad->write_batch_idled = 0;

--------------050008060307010204060504--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
