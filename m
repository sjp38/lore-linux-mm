Date: Thu, 1 Mar 2001 10:54:58 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Oops in swap code
Message-ID: <20010301105458.A7455@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

Just saw this from a Red Hat beta (wolverine) user: ring any bells?

It's a kernel BUG() in activate_page_nolock():

/*
 * Move an inactive page to the active list.
 */
void activate_page_nolock(struct page * page)
{
	if (PageInactiveDirty(page)) {
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		del_page_from_inactive_dirty_list(page);
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 
		add_page_to_active_list(page);
	} else if (PageInactiveClean(page)) {
		del_page_from_inactive_clean_list(page);
		add_page_to_active_list(page)d_page+0/4096]

kernel BUG at swap.c:201!
invalid operand: 0000
CPU:    0
EIP:    0010:[activate_page_nolock+110/528]
EIP:    0010:[<c012aaae>]
EFLAGS: 00010282
eax: 0000001a   ebx: c1103ef4   ecx: fffffffe   edx: 00000000
esi: c1103ef4   edi: 00000070   ebp: 00000000   esp: c1167f94
ds: 0018   es: 0018   ss: 0018
Process kswapd (pid: 3, stackpage=c1167000)
Stack: c020a29b c020a456 000000c9 c1103ef4 c012a822 c1103ef4 c1103f10 c012c295 
       c1103ef4 00010f00 c024f5e0 00000006 0008e000 c012c5d7 00000006 00000000 
       c0105000 0008e000 00000000 00000018 00000018 c1177fa8 c0105000 c0107576 
Call Trace: [age_page_up_nolock+18/48] [refill_inactive_scan+101/240] [kswapd+119/240] [empty_bad_page+0/4096] [empty_bad_page+0/4096] [kernel_thread+38/48] [kswapd+0/240] 
Call Trace: [<c012a822>] [<c012c295>] [<c012c5d7>] [<c0105000>] [<c0105000>] [<c0107576>] [<c012c560>] 
Code: 0f 0b 83 c4 0c 8b 43 14 85 c0 75 19 68 c9 00 00 00 68 56 a4 

This seems to be reproducible.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
