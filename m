Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <51E749B3.40103@cn.fujitsu.com>
Date: Thu, 18 Jul 2013 09:49:39 +0800
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 2/2] fs/aio: Add support to aio ring pages migration
References: <51E518C0.2020908@cn.fujitsu.com> <20130716133450.GD5403@kvack.org> <51E66256.9020203@cn.fujitsu.com> <20130717134428.GB19643@kvack.org>
In-Reply-To: <20130717134428.GB19643@kvack.org>
Content-Type: multipart/mixed;
 boundary="------------080909070003070408090001"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Al Viro <viro@zeniv.linux.org.uk>, tangchen <tangchen@cn.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-aio@kvack.org

This is a multi-part message in MIME format.
--------------080909070003070408090001
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1

Hi Ben,

On 07/17/2013 09:44 PM, Benjamin LaHaise wrote:

> On Wed, Jul 17, 2013 at 05:22:30PM +0800, Gu Zheng wrote:
>> As the aio job will pin the ring pages, that will lead to mem migrated
>> failed. In order to fix this problem we use an anon inode to manage the aio ring
>> pages, and  setup the migratepage callback in the anon inode's address space, so
>> that when mem migrating the aio ring pages will be moved to other mem node safely.
>>
>> v1->v2:
>> 	Fix build failed issue if CONFIG_MIGRATION disabled.
>> 	Fix some minor issues under Benjamin's comments.
> 
> I don't know what you did with this patch, but it doesn't apply to any of 
> the trees I can find, and interdiff isn't able to compare it against your 
> original patch.  Since the first version of the patch was already applied 
> it is generally more appropriate to provide an incremental fix.  I've 
> added the following to my tree (git://git.kvack.org/~bcrl/aio-next.git/) 
> to fix the build issue.  I've tested this with CONFIG_MIGRATION enabled 
> and disabled on x86.

My patch is applied on 3.10 release. I'm sorry that my working department is
forbidden to access all the urls based on git protocol, so I can not make patch on
your aio_next. Does aio_next have trees based on http/https protocol?

Your fix looks very well.
IMHO, because we *extern* the migrate_page_move_mapping(), so we have
the duty to make sure it can work well all the place. If some one later use 
migrate_page_move_mapping() with out the protection of CONFIG_MIGRATION,
it will lead to build-fail if CONFIG_MIGRATION is disable. So I think the
following change(return ENOSYS error is CONFIG_MIGRATION disabled) is still needed.

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index c407d88..3d0a486 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -88,6 +88,13 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 	return -ENOSYS;
 }
 
+static inline int migrate_page_move_mapping(struct address_space *mapping,
+		struct page *newpage, struct page *page,
+		struct buffer_head *head, enum migrate_mode mode)
+{
+	return -ENOSYS;
+}
+
 /* Possible settings for the migrate_page() method in address_operations */
 #define migrate_page NULL
 #define fail_migrate_page NULL



Best regards,
Gu

> 
> 		-ben



--------------080909070003070408090001
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
 name="diff.patch"
Content-Disposition: attachment;
 filename="diff.patch"

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index c407d88..3d0a486 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -88,6 +88,13 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 	return -ENOSYS;
 }
 
+static inline int migrate_page_move_mapping(struct address_space *mapping,
+		struct page *newpage, struct page *page,
+		struct buffer_head *head, enum migrate_mode mode)
+{
+	return -ENOSYS;
+}
+
 /* Possible settings for the migrate_page() method in address_operations */
 #define migrate_page NULL
 #define fail_migrate_page NULL

--------------080909070003070408090001--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
