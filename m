Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: kernel: __alloc_pages: 1-order allocation failed
Date: Fri, 31 Aug 2001 00:19:54 +0200
References: <Pine.LNX.4.21.0108271928250.7385-100000@freak.distro.conectiva> <20010829175351Z16158-32383+2308@humbolt.nl.linux.org> <3B8E4CB7.4010509@syntegra.com>
In-Reply-To: <3B8E4CB7.4010509@syntegra.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <20010830221315Z16034-32383+2530@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Kay <Andrew.J.Kay@syntegra.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On August 30, 2001 04:24 pm, Andrew Kay wrote:
> > I'm willing to guess at this point that this atomic failure is not a bug, the 
> > only bug is that we print the warning message, potentially slowing things 
> > down.  I'd like to see a correct backtrace first.
> > 
> > Do you detect any slowdown in your system when you're getting these messages? 
> > I wouldn't expect so from what you've described so far.
> 
> I don't notice any slowdown in the system, but certain operations hang. 
>   Such as vmstat, ps, and our SMTP server.  They lock up completely. 
> The load average is at 20, but the CPU is completely idle.

Ouch.  I don't have any particular difficulty figuring out where the failures
are coming from - I have some ideas on what to do about them, but those lock-ups
don't make sense given the information you've supplied.  Would you try this on
2.4.9-ac4 please?

Also, the backtrace now makes sense, but just for the first 6 entries.  Now that
you have your System.map properly linked, klogd should be decoding the backtrace.
What version is your klogd?  Is your network code in modules or compiled in?

Could you supply a ps -aux that shows your hung processes?  Even better,
backtrace with SysReq.

> Here's another attempt at ksymoops output:
> Trace; c0129b60 <_alloc_pages+18/1c>
> Trace; c0129e0e <__get_free_pages+a/18>
> Trace; c0126e7a <kmem_cache_grow+ce/234>
> Trace; c0127029 <kmem_cache_alloc+49/58>
> Trace; c01f8242 <sk_alloc+12/58>
> Trace; c021c02a <tcp_create_openreq_child+16/44c>
> Trace; c0219a6b <tcp_v4_syn_recv_sock+57/248>
> Trace; c021c6b1 <tcp_check_req+251/380>
> Trace; c01a9024 <speedo_refill_rx_buf+40/20c>
> Trace; c0206464 <ip_output+0/f0>
> Trace; c0200413 <qdisc_restart+13/c8>
> Trace; c0206464 <ip_output+0/f0>
> Trace; c01fc517 <dev_queue_xmit+117/264>
> Trace; c0206464 <ip_output+0/f0>
> Trace; c020651d <ip_output+b9/f0>
> Trace; c0206464 <ip_output+0/f0>
> Trace; c0206935 <ip_queue_xmit+3e1/540>
> Trace; c0106bf4 <ret_from_intr+0/7>
> Trace; c0206400 <ip_mc_output+108/16c>
> Trace; c01fa441 <skb_copy_and_csum_bits+51/35c>
> Trace; c0206935 <ip_queue_xmit+3e1/540>
> Trace; c01fa441 <skb_copy_and_csum_bits+51/35c>
> Trace; c01f8fc3 <skb_release_data+67/70>
> Trace; c01f8fd7 <kfree_skbmem+b/58>
> Trace; c01f910b <__kfree_skb+e7/f0>
> Trace; c0219c9e <tcp_v4_hnd_req+42/150>
> Trace; c0219f3d <tcp_v4_do_rcv+91/108>
> Trace; c021a35b <tcp_v4_rcv+3a7/618>
> Trace; c020414f <ip_local_deliver+eb/164>
> Trace; c02044a9 <ip_rcv+2e1/338>
> Trace; c01a8de4 <speedo_interrupt+b0/2b0>
> Trace; c01fca3d <net_rx_action+135/208>
> Trace; c0116f6d <do_softirq+5d/ac>
> Trace; c0107ff4 <do_IRQ+98/a8>
> Trace; c01051a0 <default_idle+0/28>
> Trace; c01051a0 <default_idle+0/28>
> Trace; c0106bf4 <ret_from_intr+0/7>
> Trace; c01051a0 <default_idle+0/28>
> Trace; c01051a0 <default_idle+0/28>
> Trace; c01051c3 <default_idle+23/28>
> Trace; c0105224 <cpu_idle+3c/50>
> Trace; c0105000 <_stext+0/0>
> Trace; c0105027 <rest_init+27/28>
> Trace; c0129b60 <_alloc_pages+18/1c>
> Trace; c0129e0e <__get_free_pages+a/18>
> Trace; c0126e7a <kmem_cache_grow+ce/234>
> Trace; c0127029 <kmem_cache_alloc+49/58>
> Trace; c01f8242 <sk_alloc+12/58>
> Trace; c021c02a <tcp_create_openreq_child+16/44c>
> Trace; c0219a6b <tcp_v4_syn_recv_sock+57/248>
> Trace; c021c6b1 <tcp_check_req+251/380>
> Trace; c01a9024 <speedo_refill_rx_buf+40/20c>
> Trace; c01a954e <speedo_rx+326/344>
> Trace; c0206464 <ip_output+0/f0>
> Trace; c0200413 <qdisc_restart+13/c8>
> Trace; c0206464 <ip_output+0/f0>
> Trace; c01fc517 <dev_queue_xmit+117/264>
> Trace; c0206464 <ip_output+0/f0>
> Trace; c020651d <ip_output+b9/f0>
> Trace; c0206464 <ip_output+0/f0>
> Trace; c0206935 <ip_queue_xmit+3e1/540>
> Trace; c01fc517 <dev_queue_xmit+117/264>
> Trace; c0206464 <ip_output+0/f0>
> Trace; c020651d <ip_output+b9/f0>
> Trace; c0206464 <ip_output+0/f0>
> Trace; c0214500 <tcp_transmit_skb+36c/540>
> Trace; c0214627 <tcp_transmit_skb+493/540>
> Trace; c02150bf <tcp_write_xmit+18f/2dc>
> Trace; c01f8fc3 <skb_release_data+67/70>
> Trace; c01f8fd7 <kfree_skbmem+b/58>
> Trace; c01f910b <__kfree_skb+e7/f0>
> Trace; c0219c9e <tcp_v4_hnd_req+42/150>
> Trace; c0219f3d <tcp_v4_do_rcv+91/108>
> Trace; c021a35b <tcp_v4_rcv+3a7/618>
> Trace; c020414f <ip_local_deliver+eb/164>
> Trace; c02044a9 <ip_rcv+2e1/338>
> Trace; c01a8de4 <speedo_interrupt+b0/2b0>
> Trace; c01fca3d <net_rx_action+135/208>
> Trace; c0116f6d <do_softirq+5d/ac>
> Trace; c0107ff4 <do_IRQ+98/a8>
> Trace; c01051a0 <default_idle+0/28>
> Trace; c01051a0 <default_idle+0/28>
> Trace; c0106bf4 <ret_from_intr+0/7>
> Trace; c01051a0 <default_idle+0/28>
> Trace; c01051a0 <default_idle+0/28>
> Trace; c01051c3 <default_idle+23/28>
> Trace; c0105224 <cpu_idle+3c/50>
> Trace; c0105000 <_stext+0/0>
> Trace; c0105027 <rest_init+27/28>

--
Daniel 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
