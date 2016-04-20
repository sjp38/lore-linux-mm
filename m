Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id ABEAB828E1
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 13:28:01 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id t5so107517977qkc.1
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 10:28:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v2si4835759qhc.83.2016.04.20.10.28.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 10:28:00 -0700 (PDT)
Date: Wed, 20 Apr 2016 18:27:55 +0100
From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: post-copy is broken?
Message-ID: <20160420172754.GJ2263@work-vm>
References: <20160414162230.GC9976@redhat.com>
 <20160415125236.GA3376@node.shutemov.name>
 <20160415134233.GG2229@work-vm>
 <20160415152330.GB3376@node.shutemov.name>
 <20160415163448.GJ2229@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E04181101@shsmsx102.ccr.corp.intel.com>
 <20160418095528.GD2222@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E0418115C@shsmsx102.ccr.corp.intel.com>
 <20160418101555.GE2222@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E041813A6@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E041813A6@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, Amit Shah <amit.shah@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>


Hi,
  Just a follow up with a little more debug;

I modified the test so it doesn't quit after the first miscomparison (see
diff below), and looking on the failures on real hardware I've seen:

/x86_64/postcopy: Memory content inconsistency at 3800000 first_byte = 30 last_byte = 30 current = 10 hit_edge = 0
                  Memory content inconsistency at 38fe000 first_byte = 30 last_byte = 10 current = 30 hit_edge = 0

and then another time:
/x86_64/postcopy: Memory content inconsistency at 4c00000 first_byte = 9a last_byte = 99 current = 1 hit_edge = 1
                  Memory content inconsistency at 4cec000 first_byte = 9a last_byte = 1 current = 99 hit_edge = 1

so in both cases what we're seeing there is starting on a 2M page boundary, a page
that is read on the destination as zero instead of getting the migrated value -
but somewhere later in the page it starts behaving. (in the first example the counter
had reached 0x30 - except for those pages which hadn't been transferred where
the counter is much lower at 0x10).

Testing it in my VM, I added some debug for where I'd been doing an madvise DONTNEED
previously:

ram_discard_range: pc.ram:0xf51000 for 42094592
ram_discard_range: pc.ram:0x5259000 for 18509824
Memory content inconsistency at f51000 first_byte = 6d last_byte = 6d current = 9e hit_edge = 0
Memory content inconsistency at 1000000 first_byte = 6d last_byte = 9e current = 6d hit_edge = 0

   So that's saying that from f51000..1000000 it was wrong - so not just one page, but upto the THP edge.
(It then got back to the right value - 6d - on the page edge).  Note how the start corresponds
to the address I'd previously done a discard on, but not the whole discard range - just
upto the THP page boundary.  Nothing in my userspace code knows about THP
(other than turning it off).

Dave



@@ -251,6 +251,7 @@ static void check_guests_ram(void)
     uint8_t first_byte;
     uint8_t last_byte;
     bool hit_edge = false;
+    bool bad = false;
 
     qtest_memread(global_qtest, start_address, &first_byte, 1);
     last_byte = first_byte;
@@ -271,11 +272,12 @@ static void check_guests_ram(void)
                                 " first_byte = %x last_byte = %x current = %x"
                                 " hit_edge = %x\n",
                                 address, first_byte, last_byte, b, hit_edge);
-                assert(0);
+                bad = true;
             }
         }
         last_byte = b;
     }
+    assert(!bad);
     fprintf(stderr, "first_byte = %x last_byte = %x hit_edge = %x OK\n",
                     first_byte, last_byte, hit_edge);
 }

--
Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
