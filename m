Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 623D76B0071
	for <linux-mm@kvack.org>; Thu, 24 Jun 2010 09:58:30 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/2 v5] Livelock avoidance for data integrity writes
Date: Thu, 24 Jun 2010 15:57:45 +0200
Message-Id: <1277387867-5525-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: inux-fsdevel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, david@fromorbit.com
List-ID: <linux-mm.kvack.org>


  Hi,

  this is an update of my patches to implement livelock avoidance for data
integrity writes using page tagging. There are some minor changes against
the previous versions:
  * fixed some whitespace problems spotted checkpatch
  * added WARN_ON_ONCE to catch a problem if radix_tree_range_tag_if_tagged
    tags more pages than we asked
  * fixed radix_tree_range_tag_if_tagged to tag at most as many pages as
    we asked (it could tag one page more).

  The patch now passed also XFSQA for XFS (well, several tests failed - like
192, 195, 228 ... - but they don't seem to be related - they are atime test,
ctime test, file alignment test, ...). Also the radix tree code passed through
10000 iterations of the following test I've implemented in Andrew's rtth:

void copy_tag_check(void)
{
        RADIX_TREE(tree, GFP_KERNEL);
        unsigned long idx[ITEMS];
        unsigned long start, end, count = 0, tagged, cur, tmp;
        int i;

//      printf("generating radix tree indices...\n");
        start = rand();
        end = rand();
        if (start > end && (rand() % 10)) {
                cur = start;
                start = end;
                end = cur;
        }
        /* Specifically create items around the start and the end of the range
         * with high probability to check for off by one errors */
        cur = rand();
        if (cur & 1) {
                item_insert(&tree, start);
                if (cur & 2) {
                        if (start <= end)
                                count++;
                        item_tag_set(&tree, start, 0);
                }
        }
        if (cur & 4) {
                item_insert(&tree, start-1);
               if (cur & 8)
                        item_tag_set(&tree, start-1, 0);
        }
        if (cur & 16) {
                item_insert(&tree, end);
                if (cur & 32) {
                        if (start <= end)
                                count++;
                        item_tag_set(&tree, end, 0);
                }
        }
        if (cur & 64) {
                item_insert(&tree, end+1);
                if (cur & 128)
                        item_tag_set(&tree, end+1, 0);
        }

        for (i = 0; i < ITEMS; i++) {
                do {
                        idx[i] = rand();
                } while (item_lookup(&tree, idx[i]));

                item_insert(&tree, idx[i]);
                if (rand() & 1) {
                        item_tag_set(&tree, idx[i], 0);
                        if (idx[i] >= start && idx[i] <= end)
                                count++;
                }
/*              if (i % 1000 == 0)
                        putchar('.'); */
        }

//      printf("\ncopying tags...\n");
        cur = start;
        tagged = radix_tree_range_tag_if_tagged(&tree, &cur, end, ITEMS, 0, 1);

//      printf("checking copied tags\n");
        assert(tagged == count);
        check_copied_tags(&tree, start, end, idx, ITEMS, 0, 1);

        /* Copy tags in several rounds */
//      printf("\ncopying tags...\n");
        cur = start;
        do {
                tmp = rand() % (count/10+2);
                tagged = radix_tree_range_tag_if_tagged(&tree, &cur, end, tmp, 0
        } while (tmp == tagged);

//      printf("%lu %lu %lu\n", tagged, tmp, count);
//      printf("checking copied tags\n");
        check_copied_tags(&tree, start, end, idx, ITEMS, 0, 2);
        assert(tagged < tmp);
//      printf("\n");
        item_kill_tree(&tree);
}

								Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
