Subject: [PATCH] aic7xxx parallel build
From: John Cherry <cherry@osdl.org>
Content-Type: multipart/mixed; boundary="=-hLxl7l5tTsbRel96GUyG"
Message-Id: <1074800332.29125.55.camel@cherrypit.pdx.osdl.net>
Mime-Version: 1.0
Date: Thu, 22 Jan 2004 11:38:53 -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Justin T. Gibbs" <gibbs@scsiguy.com>, akpm@osdl.org
Cc: linux-mm@kvack.org, linux-scsi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--=-hLxl7l5tTsbRel96GUyG
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

The Makefiles for aic7xxx and aicasm have changed since I submitted a
patch for the parallel build problem several months ago.  Justin's patch
has disappeared from the mm builds, so we continue to have parallel
build problems.

The following patch fixes the parallel build problem and it still
applies to 2.6.2-rc1-mm1.  This is Justin's fix.

John



--=-hLxl7l5tTsbRel96GUyG
Content-Disposition: attachment; filename=patch.aic7xxx_par_build
Content-Type: text/plain; name=patch.aic7xxx_par_build; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- linux-2.6.0/drivers/scsi/aic7xxx/aicasm/Makefile	2003-11-09 16:45:05.000000000 -0800
+++ 25/drivers/scsi/aic7xxx/aicasm/Makefile	2003-12-22 20:17:16.000000000 -0800
@@ -49,14 +49,18 @@ aicdb.h:
 clean:
 	rm -f $(clean-files)
 
-aicasm_gram.c aicasm_gram.h: aicasm_gram.y
+aicasm_gram.c: aicasm_gram.h
+	mv $(<:.h=).tab.c $(<:.h=.c)
+
+aicasm_gram.h: aicasm_gram.y
 	$(YACC) $(YFLAGS) -b $(<:.y=) $<
-	mv $(<:.y=).tab.c $(<:.y=.c)
 	mv $(<:.y=).tab.h $(<:.y=.h)
 
-aicasm_macro_gram.c aicasm_macro_gram.h: aicasm_macro_gram.y
+aicasm_macro_gram.c: aicasm_macro_gram.h
+	mv $(<:.h=).tab.c $(<:.h=.c)
+
+aicasm_macro_gram.h: aicasm_macro_gram.y
 	$(YACC) $(YFLAGS) -b $(<:.y=) -p mm $<
-	mv $(<:.y=).tab.c $(<:.y=.c)
 	mv $(<:.y=).tab.h $(<:.y=.h)
 
 aicasm_scan.c: aicasm_scan.l
--- linux-2.6.0/drivers/scsi/aic7xxx/Makefile	2003-11-09 16:45:05.000000000 -0800
+++ 25/drivers/scsi/aic7xxx/Makefile	2003-12-22 20:17:16.000000000 -0800
@@ -58,7 +58,9 @@ aicasm-7xxx-opts-$(CONFIG_AIC7XXX_REG_PR
 	-p $(obj)/aic7xxx_reg_print.c -i aic7xxx_osm.h
 
 ifeq ($(CONFIG_AIC7XXX_BUILD_FIRMWARE),y)
-$(aic7xxx-gen-y): $(src)/aic7xxx.seq $(src)/aic7xxx.reg $(obj)/aicasm/aicasm
+$(aic7xxx-gen-y): $(src)/aic7xxx.seq
+
+$(src)/aic7xxx.seq: $(obj)/aicasm/aicasm $(src)/aic7xxx.reg
 	$(obj)/aicasm/aicasm -I$(src) -r $(obj)/aic7xxx_reg.h \
 			      $(aicasm-7xxx-opts-y) -o $(obj)/aic7xxx_seq.h \
 			      $(src)/aic7xxx.seq
@@ -72,7 +74,9 @@ aicasm-79xx-opts-$(CONFIG_AIC79XX_REG_PR
 	-p $(obj)/aic79xx_reg_print.c -i aic79xx_osm.h
 
 ifeq ($(CONFIG_AIC79XX_BUILD_FIRMWARE),y)
-$(aic79xx-gen-y): $(src)/aic79xx.seq $(src)/aic79xx.reg $(obj)/aicasm/aicasm
+$(aic79xx-gen-y): $(src)/aic79xx.seq
+
+$(src)/aic79xx.seq: $(obj)/aicasm/aicasm $(src)/aic79xx.reg
 	$(obj)/aicasm/aicasm -I$(src) -r $(obj)/aic79xx_reg.h \
 			      $(aicasm-79xx-opts-y) -o $(obj)/aic79xx_seq.h \
 			      $(src)/aic79xx.seq

--=-hLxl7l5tTsbRel96GUyG--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
