Date: Mon, 08 Jul 2002 10:29:23 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <9820000.1026149363@flay>
In-Reply-To: <1048271645.1025997192@[10.10.2.3]>
References: <3D27AC81.FC72D08F@zip.com.au> <1048271645.1025997192@[10.10.2.3]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

OK, here's the data from Keith that I was promising on kmap. This was just
for a kernel compile. So copy_strings and file_read_actor seem to be the
main users (for this workload) by an order of magnitude.

                0.00    0.00       1/3762429     remove_arg_zero [618]
                0.00    0.00      10/3762429     ext2_set_link [576]
                0.00    0.00     350/3762429     block_read_full_page [128]
                0.00    0.00     750/3762429     ext2_empty_dir [476]
                0.02    0.00   11465/3762429     ext2_delete_entry [217]
                0.02    0.00   12983/3762429     ext2_inode_by_name [228]
                0.03    0.00   15400/3762429     ext2_add_link [182]
                0.03    0.00   16621/3762429     ext2_find_entry [198]
                0.06    0.00   33016/3762429     ext2_readdir [79]
                0.13    0.00   71900/3762429     generic_file_write [109]
                0.17    0.00   95589/3762429     generic_commit_write [255]
                2.25    0.00 1229513/3762429     file_read_actor [50]
                4.15    0.00 2274831/3762429     copy_strings [36]
[105]    0.2    6.87    0.00 3762429         kunmap_high [105]


and 

                0.00    0.00       1/3762429     remove_arg_zero [618]
                0.00    0.00     350/3762429     block_read_full_page [128]
                0.22    0.01   71900/3762429     generic_file_write [109]
                0.27    0.01   90245/3762429     ext2_get_page [176]
                0.29    0.01   95589/3762429     _block_prepare_write [141]
                3.72    0.11 1229513/3762429     file_read_actor [50]
                6.88    0.21 2274831/3762429     copy_strings [36]
[87]     0.3   11.38    0.35 3762429         kmap_high [87]
                0.35    0.00      27/27          flush_all_zero_pkmaps [273]

this kernel had a larger kmap area (which is why flush_all_zero_pkmaps is
only called so little).  It is a 2.4.18 tree with O(1) sched.

----------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
