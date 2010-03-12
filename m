Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 132156B015A
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 14:38:26 -0500 (EST)
Date: Fri, 12 Mar 2010 20:38:14 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] x86, UV: BAU performance and error recovery
Message-ID: <20100312193814.GA27306@elte.hu>
References: <E1Nq5yy-0006ot-8E@eag09.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1Nq5yy-0006ot-8E@eag09.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
To: Cliff Wickman <cpw@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


* Cliff Wickman <cpw@sgi.com> wrote:

>  static void uv_bau_process_message(struct bau_payload_queue_entry *msg,
> +			int msg_slot, int sw_ack_slot, struct bau_control *bcp,
> +			struct bau_payload_queue_entry *va_queue_first,
> +			struct bau_payload_queue_entry *va_queue_last)

this function really needs a cleanup - some helper structure that can be 
passed along, instead of these 6 parameters from hell.

Also:

> +	int i;
> +	int sending_cpu;
> +	int msg_ack_count;
> +	int slot2;
> +	int cancel_count = 0;
> +	unsigned char this_sw_ack_vector;
> +	short socket_ack_count = 0;
> +	unsigned long mmr = 0;
> +	unsigned long msg_res;
> +	struct ptc_stats *stat;
> +	struct bau_payload_queue_entry *msg2;
> +	struct bau_control *smaster = bcp->socket_master;
>  
> +	/*
> +	 * This must be a normal message, or retry of a normal message
> +	 */
> +	stat = &per_cpu(ptcstats, bcp->cpu);
>  	if (msg->address == TLB_FLUSH_ALL) {
>  		local_flush_tlb();
> -		__get_cpu_var(ptcstats).alltlb++;
> +		stat->d_alltlb++;
>  	} else {
>  		__flush_tlb_one(msg->address);
> -		__get_cpu_var(ptcstats).onetlb++;
> +		stat->d_onetlb++;
>  	}
> +	stat->d_requestee++;
>  
> -	__get_cpu_var(ptcstats).requestee++;
> +	/*
> +	 * One cpu on each blade has the additional job on a RETRY
> +	 * of releasing the resource held by the message that is
> +	 * being retried.  That message is identified by sending
> +	 * cpu number.
> +	 */
> +	if (msg->msg_type == MSG_RETRY && bcp == bcp->pnode_master) {
> +		sending_cpu = msg->sending_cpu;
> +		this_sw_ack_vector = msg->sw_ack_vector;
> +		stat->d_retries++;
> +		/*
> +		 * cancel any from msg+1 to the retry itself
> +		 */
> +		bcp->retry_message_scans++;
> +		for (msg2 = msg+1, i = 0; i < DEST_Q_SIZE; msg2++, i++) {
> +			if (msg2 > va_queue_last)
> +				msg2 = va_queue_first;
> +			if (msg2 == msg)
> +				break;
> +
> +			/* uv_bau_process_message: same conditions
> +			   for cancellation as uv_do_reset */
> +			if ((msg2->replied_to == 0) &&
> +			    (msg2->canceled == 0) &&
> +			    (msg2->sw_ack_vector) &&
> +			    ((msg2->sw_ack_vector &
> +				this_sw_ack_vector) == 0) &&
> +			    (msg2->sending_cpu == sending_cpu) &&
> +			    (msg2->msg_type != MSG_NOOP)) {
> +				bcp->retry_message_actions++;
> +				slot2 = msg2 - va_queue_first;
> +				mmr = uv_read_local_mmr
> +				(UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE);
> +				msg_res = ((msg2->sw_ack_vector << 8) |
> +					   msg2->sw_ack_vector);
> +				/*
> +				 * If this message timed out elsewhere
> +				 * so that a retry was broadcast, it
> +				 * should have timed out here too.
> +				 * It is not 'replied_to' so some local
> +				 * cpu has not seen it.  When it does
> +				 * get around to processing the
> +				 * interrupt it should skip it, as
> +				 * it's going to be marked 'canceled'.
> +				 */
> +				msg2->canceled = 1;
> +				cancel_count++;
> +				/*
> +				 * this is a message retry; clear
> +				 * the resources held by the previous
> +				 * message or retries even if they did
> +				 * not time out
> +				 */
> +				if (mmr & msg_res) {
> +					stat->d_canceled++;
> +					uv_write_local_mmr(
> +			    UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE_ALIAS,
> +						msg_res);
> +				}
> +			}
> +		}
> +		if (!cancel_count)
> +			stat->d_nocanceled++;
> +	}
>  
> +	/*
> +	 * This is a sw_ack message, so we have to reply to it.
> +	 * Count each responding cpu on the socket. This avoids
> +	 * pinging the count's cache line back and forth between
> +	 * the sockets.
> +	 */
> +	socket_ack_count = atomic_add_short_return(1, (struct atomic_short *)
> +				&smaster->socket_acknowledge_count[msg_slot]);
> +	if (socket_ack_count == bcp->cpus_in_socket) {
> +		/*
> +		 * Both sockets dump their completed count total into
> +		 * the message's count.
> +		 */
> +		smaster->socket_acknowledge_count[msg_slot] = 0;
> +		msg_ack_count = atomic_add_short_return(socket_ack_count,
> +				(struct atomic_short *)&msg->acknowledge_count);
> +
> +		if (msg_ack_count == bcp->cpus_in_blade) {
> +			/*
> +			 * All cpus in blade saw it; reply
> +			 */
> +			uv_reply_to_message(msg_slot, sw_ack_slot, msg, bcp);
> +		}
> +	}
> +

This function is way too large and suffers from various col80 artifacts, the 
pinacle of which is probably this:

> +					uv_write_local_mmr(
> +			    UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE_ALIAS,
> +						msg_res);

Helper inlines and other tricks could reduce its size and reduce the per 
function complexity.

> +	return;
> +}

Totally unnecessary return statement.

Really, this code is pretty ugly and should be restructured to be a lot easier 
to read and easier to maintain.

If this patch works for you we can do this as a smaller series of that patch 
plus a cleanup patch (for easier debuggability), but we really want a cleaner 
thing than this ...

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
