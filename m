Received: from mail.ccr.net (ccr@alogconduit1au.ccr.net [208.130.159.21])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA17289
	for <linux-mm@kvack.org>; Tue, 19 Jan 1999 10:43:44 -0500
Subject: Re: Why don't shared anonymous mappings work?
References: <199901132131.OAA09149@nyx10.nyx.net> <199901191432.OAA05326@dax.scot.redhat.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 19 Jan 1999 09:23:44 -0600
In-Reply-To: "Stephen C. Tweedie"'s message of "Tue, 19 Jan 1999 14:32:34 GMT"
Message-ID: <m1hftnxp4v.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Colin Plumb <colin@nyx.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:

ST> Hi,
ST> On Wed, 13 Jan 1999 14:31:41 -0700 (MST), Colin Plumb <colin@nyx.net>
ST> said:

>> Um, I just thought of another problem with shared anonymous pages.
>> It's similar to the zero-page issue you raised, but it's no longer
>> a single special case.

>> Copy-on-write and shared mappings.  Let's say that process 1 has a COW
>> copy of page X.  Then the page is shared (via mmap /proc/1/mem or some
>> such) with process 2.  Now process A writes to the page.

ST> Invalid argument.  This is *precisely* why mmap of /proc/X/mem is
ST> broken.  We don't need to implement reasonable semantics for that case,
ST> because there _are_ no reasonable semantics for a page which can be both
ST> MAP_PRIVATE and MAP_SHARED in the same process.

Thank you for stomping on this, and my apologies a while ago for bringing it up.  

Dosemu keeps coming to my mind.  For 2.3 we need a better version of shared
memory for dosemu to use.  shm is fine but it's not flexible enough.

For multiple MAP_PRIVATE & MAP_SHARED mappings, the most we can
theoretically allow is:
o If a page is updated, we need to update at most the page table entry, the write came from.
o If a write did not come from a page table entry we need to update no page table entries.
o During a mapping we need to update at most one old pte per page, and old
  pte's that are updated must be in the same mm.

With those guidelines the best we can allow for /proc/self/mem is to
promote the page into a shared anonymous mapping, or fail.

Anything else would break the guidelines above.  Which are what we need
if we want to avoid reverse page table entries, which is reasonable.

Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
